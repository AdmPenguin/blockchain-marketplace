// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This tests reentrancy attacks, which would allow an attacker to drain the contract of funds
// If this test fails, the contract can be drained by either a bidder, a seller, or a combination of both working together

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";