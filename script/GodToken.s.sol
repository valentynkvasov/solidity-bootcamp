// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {GodToken} from "../src/GodToken.sol";

contract GodTokenScript is Script {
    GodToken public godToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        godToken = new GodToken(100);

        vm.stopBroadcast();
    }
}
