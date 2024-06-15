// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This tests whether a malicious attacker can call functions they shouldn't be able to.
// If this fails, this can grant the attacker significant control over the contract.


import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";
import { MarketPlace } from "../src/faceBlock.sol";

contract FunctionManipulationTest is Test {
    // test login from different account

    // test to see if non-owner can transfer items


}

