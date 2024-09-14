// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {CurveToken} from "../src/CurveToken.sol";

contract SanctionTokenScript is Script {
    CurveToken public curveToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        curveToken = new CurveToken();

        vm.stopBroadcast();
    }
}
