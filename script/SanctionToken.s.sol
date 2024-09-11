// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {SanctionToken} from "../src/SanctionToken.sol";

contract SanctionTokenScript is Script {
    SanctionToken public sanctionToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        sanctionToken = new SanctionToken(100);

        vm.stopBroadcast();
    }
}
