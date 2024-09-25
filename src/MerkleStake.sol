// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts@v4.9.6/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@v4.9.6/access/Ownable2Step.sol";
import "@openzeppelin/contracts@v4.9.6/token/common/ERC2981.sol";
import "@openzeppelin/contracts@v4.9.6/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts@v4.9.6/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC721/IERC721Receiver.sol";

contract NFTToken is ERC721, ERC2981, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 public constant MAX_SUPPLY = 1000;

    uint256 public currentSupply = 0;
    uint96 private constant ROYALTY_FEE_NUMERATOR = 250;

    bytes32 public merkleRoot;
    BitMaps.BitMap private claimedMints;

    constructor(bytes32 _merkleRoot) ERC721("MyLimitedNFT", "MLN") {
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(msg.sender, ROYALTY_FEE_NUMERATOR);
    }

    function mintNFT(bytes32[] calldata proof) external {
        require(currentSupply < MAX_SUPPLY, "All NFTs have been minted.");
        require(isEligibleToMint(msg.sender, proof), "You are not eligible to mint.");
        require(!claimedMints.get(uint256(uint160(msg.sender))), "Mint already claimed.");

        claimedMints.set(uint256(uint160(msg.sender)));

        currentSupply += 1;
        _safeMint(msg.sender, currentSupply);
    }

    function isEligibleToMint(address account, bytes32[] calldata proof) private view returns (bool) {
        return MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(account)));
    }

    function withdrawFunds() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed.");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
}

contract RewardToken is ERC20, Ownable2Step {
    constructor() ERC20("RewardToken", "RWT") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

contract NFTStaking is IERC721Receiver, Ownable2Step {

    NFTToken public nftToken;
    RewardToken public rewardToken;
    uint256 public rewardRatePerDay = 10 * 10 ** 18;

    struct StakedNFT {
        address staker;
        uint256 lastClaimTime;
    }

    mapping(uint256 => StakedNFT) public stakedNFTs;

    constructor(address _nftTokenAddress) {
        nftToken = NFTToken(_nftTokenAddress);
        rewardToken = new RewardToken();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == address(nftToken), "Invalid NFT contract");

        stakedNFTs[tokenId] = StakedNFT({
            staker: from,
            lastClaimTime: block.timestamp
        });

        return this.onERC721Received.selector;
    }

    function claimRewards(uint256 tokenId) public {
        StakedNFT storage stakedNFT = stakedNFTs[tokenId];

        require(stakedNFT.staker == msg.sender, "You are not the staker");
        uint256 timeElapsed = block.timestamp - stakedNFT.lastClaimTime;
        require(timeElapsed >= 24 hours, "You can only claim once every 24 hours");

        uint256 daysElapsed = timeElapsed / 24 hours;
        uint256 rewardAmount = daysElapsed * rewardRatePerDay;

        stakedNFT.lastClaimTime += daysElapsed * 24 hours;

        rewardToken.mint(msg.sender, rewardAmount);
    }

    function withdrawNFT(uint256 tokenId) public {
        StakedNFT storage stakedNFT = stakedNFTs[tokenId];

        require(stakedNFT.staker == msg.sender, "You are not the staker");

        claimRewards(tokenId);

        delete stakedNFTs[tokenId];

        nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function getStaker(uint256 tokenId) external view returns (address) {
        return stakedNFTs[tokenId].staker;
    }
}