// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This test aims to test if a self destruct attack can bypass the auction's check and allow bidding to end
// If this test fails, it could mean that an attacker can lock down bidding, preventing an item from being purchased or bid on to win the auction

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";

contract SelfDestructTest is Test {
    Users userManager;
    Items itemManager;
    Listings listingManager;

    address alice = address(0x01);
    address bob = address(0x02);
    address attacker = address(0x11);
    address selfDestructor = address(0x12);

    function setUp() public {
        userManager.registerUser("alice", "password", alice);
        userManager.registerUser("bob", "password", bob);
        userManager.registerUser("alice2", "password", attacker);
        userManager.registerUser("alice3", "password", selfDestructor);



    }

    function testAuctionSelfDestruct() {

    }

}