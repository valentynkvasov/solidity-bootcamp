// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts@v4.9.6/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts@v4.9.6/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    using SafeERC20 for IERC20;

    struct Deal {
        IERC20 token;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => mapping(address => Deal)) public deals;

    event DealCreated(address indexed buyer, address indexed seller, IERC20 token, uint256 amount);
    event DealClosed(address indexed buyer, address indexed seller, IERC20 token, uint256 amount);

    function deposit(address seller, IERC20 token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(deals[msg.sender][seller].amount == 0, "Deal already exists");

        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 actualAmount = balanceAfter - balanceBefore;
        require(actualAmount > 0, "No tokens transferred");

        deals[msg.sender][seller] = Deal({token: token, amount: actualAmount, timestamp: block.timestamp});

        emit DealCreated(msg.sender, seller, token, actualAmount);
    }

    function withdraw(address buyer) public {
        Deal memory deal = deals[buyer][msg.sender];

        require(deal.amount > 0, "No deal found");
        require(block.timestamp >= deal.timestamp + 3 days, "Too early to withdraw");

        delete deals[buyer][msg.sender];

        deal.token.safeTransfer(msg.sender, deal.amount);

        emit DealClosed(buyer, msg.sender, deal.token, deal.amount);
    }
}
