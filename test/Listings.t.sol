// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {Users} from "../src/Users.sol";
import {Items} from "../src/Items.sol";
import {Listings} from "../src/Listings.sol";

contract ListingsTest is Test {
    Users public usersContract;
    Items public itemsContract;
    Listings public listingsContract;

    address alice = address(0x01);
    address bob = address(0x02);
    address charlie = address(0x03);

    function setUp() public {

        usersContract = new Users();
        itemsContract = new Items(usersContract);
        listingsContract = new Listings(itemsContract, usersContract);

        deal(alice, 100 ether);
        deal(bob, 100 ether);
        deal(charlie, 100 ether);

        usersContract.registerUser("alice", "password", alice);
        usersContract.registerUser("bob", "password", bob);
        usersContract.registerUser("charlie", "password", charlie);

        itemsContract.createItem("Alice's Car", alice);
        itemsContract.createItem("Bob's Car", bob);
    }   

    function testCreateListing() public {
        listingsContract.createListing(1 ether, "Alice's Car", 0, 1, true, "Goleta, CA", alice);

        vm.expectRevert("Listings must be up for at least 1 day");
        listingsContract.createListing(1 ether, "Bob's Car", 1, 0, true, "Goleta, CA", bob);
        vm.expectRevert("Max Bidding Duration is 30 Days");
        listingsContract.createListing(1 ether, "Bob's Car", 1, 31, true, "Goleta, CA", bob);

    }

    function testBiddingAndSellerEnd() public {
        listingsContract.createListing(1 ether, "Alice's car, for sale", 0, 1, false, "Isla Vista, CA", alice);

        vm.startPrank(bob);
        listingsContract.bidOnListing{value: 15 ether}(0, bob);
        assertEq(listingsContract.getMinPriceForListing(0), 15 ether);
        vm.stopPrank();
        vm.startPrank(charlie);
        listingsContract.bidOnListing{value: 25 ether}(0, charlie);
        assertEq(listingsContract.getMinPriceForListing(0), 25 ether);
        vm.stopPrank();
        
        listingsContract.sellerEndBidding(0, alice);
        assertEq(itemsContract.getItemOwner(0), "charlie");

    }

}