// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This tests reentrancy attacks, which would allow an attacker to drain the contract of funds
// If this test fails, the contract can be drained by either a bidder, a seller, or a combination of both working together

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";

contract AttackerBid {

}

contract AttackerSeller {

}

contract AttackerHighestBidder {

}

contract ReentrancyTest is Test {
    Users public users;
    Items public items;
    Listings public listings;

    address alice = address(0x01);
    address attacker1Address;
    address attacker2Address;

    function setUp() public {
        users = new Users();
        items = new Items(users);
        listings = new Listings(items, users);

        users.registerUser("alice", "password", alice);
        items.createItem("Test Item", alice);
        listings.createListing(0 ether, "Test Listing", 0, 1, false, "UCSB, CA", alice);
    }

    function testBidOnListing() public {
        AttackerBid attacker1 = new AttackerBid();
        AttackerBid attacker2 = new AttackerBid();

        deal(attacker1Address, 100 ether);
        deal(attacker2Address, 100 ether);

        attacker1Address = address(attacker1);
        attacker2Address = address(attacker2);

        listings.bidOnListing{value: 1 ether}(0, attacker1Address);
        listings.bidOnListing{value: 2 ether}(0, attacker1Address);

    }

    function testSellerEndListing() public {

    }

    function highestBidderEndBiddingPostBiddingPeriod() public {

    }

}