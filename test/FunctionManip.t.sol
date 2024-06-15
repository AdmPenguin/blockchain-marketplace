// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This tests whether a malicious attacker can call functions they shouldn't be able to.
// If this fails, this can grant the attacker significant control over the contract.


import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { MarketPlace } from "../src/faceBlock.sol";

contract FunctionManipulationTest is Test {
    MarketPlace public marketplace;

    address alice = address(0x01);
    address attacker = address(0x10);

    function setUp() public {
        marketplace = new MarketPlace();

        vm.startPrank(alice);
        marketplace.createAccount("alice", "password");
        marketplace.login("alice", "password");
        marketplace.createItem("Test Item");
        vm.stopPrank();
        vm.startPrank(attacker);
        marketplace.createAccount("alice1", "password");
        vm.stopPrank();

    }

    // test login from different account
    function testLogin() public {
        vm.startPrank(attacker);
        vm.expectRevert("Login failed, wrong username and password");
        marketplace.login("alice", "password");
        vm.stopPrank();
    }

    // test to see if non-owner can transfer items
    function testTransfer() public {
        vm.startPrank(attacker);
        vm.expectRevert("Not the item owner");
        marketplace.transferItem(0, attacker);
        vm.stopPrank();
    }

    // see if a non-owner can create a listing for an item
    function testSellNonOwned() public {
        vm.startPrank(attacker);
        marketplace.login("alice1", "password");
        vm.expectRevert("Not the item owner");
        marketplace.createListing("Test Listing", 0 ether, 0, 1, true, "UCSB, CA");
        vm.stopPrank();
    }

}

