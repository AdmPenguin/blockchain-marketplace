// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Tests to see if users can call a function which is benefitial for themselves or call a function multiple times for their benefit
// This ensures that users must play fair and can't create multiple accounts or rate themselves, which would be detremential to the rating system


import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { MarketPlace } from "../src/faceBlock.sol";

contract SelfMultiCallingTest is Test {
    MarketPlace public marketplace;

    address attacker = address(0x10);

    function setUp() public {
        marketplace = new MarketPlace();
        
        vm.startPrank(attacker);
        marketplace.createAccount("alice1", "password");
        marketplace.login("alice1", "password");
        marketplace.createItem("Test Item");
        marketplace.createListing("Test Listing", 0 ether, 0, 1, true, "Goleta, CA");
        vm.stopPrank();
    }

    // tests whether or not user can sign up for multiple accounts
    function testMultiRegister() public {
        vm.startPrank(attacker);
        vm.expectRevert("User already registered");
        marketplace.createAccount("alice2", "password");
        vm.stopPrank();
    }

    function testSelfRate() public {
        vm.startPrank(attacker);
        marketplace.endListingAsSeller(0);
        vm.expectRevert("Sellers cannot rate themselves");
        marketplace.rateSellerAsWinnerOfListing(0, 5);
        vm.stopPrank();
    }

}