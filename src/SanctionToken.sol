//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC777} from "@openzeppelin/contracts@v4.9.6/token/ERC777/ERC777.sol";
import {Ownable} from "@openzeppelin/contracts@v4.9.6/access/Ownable.sol";

contract SanctionToken is ERC777, Ownable {
    mapping(address => bool) private bannedUsers;

    event UserBanned(address indexed user);

    constructor(uint256 initialSupply) ERC777("Sanction Token", "ST", new address[](0)) {
        _mint(msg.sender, initialSupply, "", "");
    }

    function banUser(address user) external onlyOwner {
        bannedUsers[user] = true;

        emit UserBanned(user);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal override {
        require(!bannedUsers[from] && !bannedUsers[to], "SanctionedToken: transfer from/to sanctioned address");
        super._beforeTokenTransfer(operator, from, to, amount);
    }
}
