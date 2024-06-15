// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Tests to see if users can call a function which is benefitial for themselves or call a function multiple times for their benefit
// This ensures that users must play fair and can't create multiple accounts or rate themselves, which would be detremential to the rating system


import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";
import { MarketPlace } from "../src/faceBlock.sol";

contract SelfMultiCallingTest is Test {
    

    // tests whether or not user can sign up for multiple accounts

}