// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {SanctionToken} from "../src/SanctionToken.sol";

contract SanctionTokenTest is Test {
    SanctionToken public sanctionToken;
    address public owner = vm.addr(1);
    uint256 public initialSupply = 100;

    function setUp() public {
        vm.prank(owner);
        sanctionToken = new SanctionToken(initialSupply);

        assertEq(sanctionToken.totalSupply(), initialSupply);
        assertEq(sanctionToken.balanceOf(owner), initialSupply);
    }

    function test_SanctionTokenSend() public {
        address firstUser = vm.addr(2);

        vm.prank(owner);
        sanctionToken.transfer(firstUser, 10);

        address secondUser = vm.addr(3);
        uint256 amount = 5;
        vm.prank(firstUser);
        sanctionToken.transfer(secondUser, amount);

        assertEq(sanctionToken.balanceOf(secondUser), amount);
    }

    function test_BanUser() public {
        address user = vm.addr(3);

        vm.startPrank(owner);
        sanctionToken.transfer(user, 10);
        sanctionToken.banUser(user);
        vm.stopPrank();

        vm.expectRevert("SanctionedToken: transfer from/to sanctioned address");
        vm.prank(user);
        sanctionToken.transfer(vm.randomAddress(), 1);

        vm.expectRevert("SanctionedToken: transfer from/to sanctioned address");
        vm.prank(owner);
        sanctionToken.transfer(user, 1);
    }
}
