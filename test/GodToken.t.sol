// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {GodToken} from "../src/GodToken.sol";

contract GodTokenTest is Test {
    GodToken public godToken;
    address public owner = vm.addr(1);
    uint256 public initialSupply = 100;

    function setUp() public {
        vm.prank(owner);
        godToken = new GodToken(initialSupply);

        assertEq(godToken.totalSupply(), initialSupply);
        assertEq(godToken.balanceOf(owner), initialSupply);
    }

    function test_GodTokenSend() public {
        address user = vm.addr(2);

        vm.startPrank(owner);
        godToken.transfer(user, 10);
        godToken.transferFrom(user, owner, 10);
        vm.stopPrank();

        assertEq(godToken.balanceOf(owner), initialSupply);
    }

    function test_GodTokenSendFromSeveralAccounts() public {
        address firstUser = vm.addr(3);
        address secondUser = vm.addr(4);

        vm.prank(owner);
        godToken.transfer(firstUser, 10);

        vm.prank(firstUser);
        godToken.transfer(secondUser, 5);

        vm.startPrank(owner);
        godToken.transferFrom(firstUser, owner, 5);
        godToken.transferFrom(secondUser, owner, 5);
        vm.stopPrank();

        assertEq(godToken.balanceOf(owner), initialSupply);
    }
}
