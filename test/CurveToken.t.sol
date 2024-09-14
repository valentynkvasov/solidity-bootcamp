// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {CurveToken} from "../src/CurveToken.sol";

contract CurveTokenTest is Test {
    CurveToken public curveToken;

    function setUp() public {
        curveToken = new CurveToken();
        assertEq(curveToken.totalSupply(), 0);
    }

    /**
     * @dev Positive Test: Verifies that a user can buy tokens by sending Ether.
     */
    function test_BuyAndSellTokens() public {
        address buyer = vm.addr(1);
        uint256 initialEtherBalance = 10 ether;
        vm.deal(buyer, initialEtherBalance);

        uint256 etherToSend = 1 ether;

        vm.prank(buyer);
        curveToken.buyTokens{value: etherToSend}();

        uint256 buyerTokenBalance = curveToken.balanceOf(buyer);
        assertGt(buyerTokenBalance, 0, "Buyer should have received tokens");

        console.log("Buyer token balance after purchase:", buyerTokenBalance);

        assertEq(curveToken.totalSupply(), buyerTokenBalance, "Total supply should match buyer's balance");

        vm.prank(buyer);
        curveToken.sellTokens(buyerTokenBalance);
        assertEq(curveToken.balanceOf(buyer), 0, "Buyer shouldn't have any tokens");
    }

    /**
     * @dev Positive Test: Verifies that a user can buy tokens by sending Ether.
     */
    function test_LinearRelationTokens() public {
        address buyer = vm.addr(1);
        uint256 initialEtherBalance = 10 ether;
        vm.deal(buyer, initialEtherBalance);

        uint256 etherToSend = 5 ether;

        vm.prank(buyer);
        curveToken.buyTokens{value: etherToSend}();

        uint256 buyerTokenBalanceAfterFirstBuy = curveToken.balanceOf(buyer);

        vm.prank(buyer);
        curveToken.buyTokens{value: etherToSend}();

        uint256 buyerTokenBalanceAfterSecondBuy = curveToken.balanceOf(buyer);

        assertGt(buyerTokenBalanceAfterSecondBuy, buyerTokenBalanceAfterFirstBuy, "Second buy should give less tokens");
    }
}
