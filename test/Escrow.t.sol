// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import {ERC20} from "@openzeppelin/contracts@v4.9.6/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts@v4.9.6/token/ERC20/IERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract EscrowTest is Test {
    Escrow escrow;
    MockERC20 token;
    address buyer = address(1);
    address seller = address(2);

    function setUp() public {
        escrow = new Escrow();

        token = new MockERC20();
        token.mint(buyer, 1000 ether);

        vm.label(buyer, "Buyer");
        vm.label(seller, "Seller");
        vm.label(address(escrow), "Escrow");
    }

    function testDeposit() public {
        vm.startPrank(buyer);
        token.approve(address(escrow), 500 ether);

        escrow.deposit(seller, IERC20(address(token)), 500 ether);
        vm.stopPrank();

        (IERC20 dealToken, uint256 dealAmount, uint256 timestamp) = escrow.deals(buyer, seller);

        assertEq(address(dealToken), address(token), "Token address mismatch");
        assertEq(dealAmount, 500 ether, "Incorrect deal amount");
        assertEq(timestamp, block.timestamp, "Incorrect timestamp");
    }

    function testWithdrawAfter3Days() public {
        vm.startPrank(buyer);
        token.approve(address(escrow), 500 ether);
        escrow.deposit(seller, IERC20(address(token)), 500 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 3 days);

        vm.prank(seller);
        escrow.withdraw(buyer);

        uint256 sellerBalance = token.balanceOf(seller);
        assertEq(sellerBalance, 500 ether, "Seller did not receive tokens");

        (IERC20 dealToken, uint256 dealAmount, uint256 timestamp) = escrow.deals(buyer, seller);
        assertEq(address(dealToken), address(0), "Deal token not reset");
        assertEq(dealAmount, 0, "Deal amount not reset");
        assertEq(timestamp, 0, "Timestamp not reset");
    }
}
