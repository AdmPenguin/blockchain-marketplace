// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {Listings} from "../src/Listings.sol";

contract TestBuyAccount {
    fallback() external payable{
    }
}

contract TestAuctionAccount {
    fallback() external payable{
    }
}

contract ListingsTest is Test {
    Listings public listings;

    address admin   =  address(0x69);
    address alice   =  address(0x01);
    address bob     =  address(0x02);
    address charlie =  address(0x03);
    address david   =  address(0x04);

    // create some test listings
    function setUp() public {
        listings = new Listings();

        // set up payment locks:
        vm.startPrank(admin);
        listings.setPaymentLock(alice);
        listings.setPaymentLock(bob);
        listings.setPaymentLock(charlie);
        listings.setPaymentLock(david);
        vm.stopPrank();

        vm.startPrank(alice);
        listings.createListing(10 ether, "Alice's Apple Pie", 1, false, "N/A");
        vm.stopPrank();

        vm.startPrank(charlie);
        listings.createListing(5 ether, "Charlie's Car", 3, true, "Santa Barbara, CA");
        vm.stopPrank();

        vm.startPrank(david);
        listings.createAuctionListing(0, "David's 1st Dish", false, "Goleta, CA");
        listings.createAuctionListing(0, "David's 2nd Dish", true, "Goleta, CA");
        listings.createAuctionListing(3 ether, "David's 3rd Dish", false, "Goleta, CA");
        vm.stopPrank();
    }

    // check test listings for correctness
    function testCreateListings() public {
        Listings.Listing[] memory testListings = listings.getListings();
        Listings.AuctionListing[] memory testAuctionListings = listings.getAuctionListings();

        Listings.Listing memory testListing0 = testListings[0];
        Listings.Listing memory testListing1 = testListings[1];

        Listings.AuctionListing memory testAuctionListing0 = testAuctionListings[0];
        Listings.AuctionListing memory testAuctionListing1 = testAuctionListings[1];
        Listings.AuctionListing memory testAuctionListing2 = testAuctionListings[2];

        assertEq(testListings.length, 2, "More or less than 2 listings were created");
        assertEq(testAuctionListings.length, 3, "More or less than 3 auction listings were created");
        
        assertEq(testListing0.id, 0, "ID not 0");
        assertEq(testListing0.price, 10 ether, "price not correctly set");
        assertEq(testListing0.seller, address(0x01), "seller not correctly set");
        assertEq(testListing0.name, "Alice's Apple Pie", "name not correctly set");
        assertEq(testListing0.stockRemaining, 1, "stock not correctly set");
        assertEq(testListing0.isShippable, false, "isShippable not correctly set");
        assertEq(testListing0.location, "N/A", "location not correctly set");

        assertEq(testListing1.id, 1, "ID not 1");
        assertEq(testListing1.price, 5 ether, "price not correctly set");
        assertEq(testListing1.seller, address(0x03), "seller not correctly set");
        assertEq(testListing1.name, "Charlie's Car", "name not correctly set");
        assertEq(testListing1.stockRemaining, 3, "stock not correctly set");
        assertEq(testListing1.isShippable, true, "isShippable not correctly set");
        assertEq(testListing1.location, "Santa Barbara, CA", "location not correctly set");

        assertEq(testAuctionListing0.id, 0, "ID not 0");
        assertEq(testAuctionListing0.price, 0, "price not correctly set");
        assertEq(testAuctionListing0.seller, address(0x04), "seller not correctly set");
        assertEq(testAuctionListing0.name, "David's 1st Dish", "Goleta, CA");
        assertEq(testAuctionListing0.currWinner, address(0x00), "winner not correctly initalized");
        assertEq(testAuctionListing0.isActive, true, "not set as active");
        assertEq(testAuctionListing0.isShippable, false, "isShippable not correctly set");
        assertEq(testAuctionListing0.location, "Goleta, CA", "location not correctly set");

        assertEq(testAuctionListing1.id, 1, "ID not 1");
        assertEq(testAuctionListing1.price, 0, "price not correctly set");
        assertEq(testAuctionListing1.seller, address(0x04), "seller not correctly set");
        assertEq(testAuctionListing1.name, "David's 2nd Dish", "Goleta, CA");
        assertEq(testAuctionListing1.currWinner, address(0x00), "winner not correctly initalized");
        assertEq(testAuctionListing1.isActive, true, "not set as active");
        assertEq(testAuctionListing1.isShippable, true, "isShippable not correctly set");
        assertEq(testAuctionListing1.location, "Goleta, CA", "location not correctly set");

        assertEq(testAuctionListing2.id, 2, "ID not 2");
        assertEq(testAuctionListing2.price, 3 ether, "price not correctly set");
        assertEq(testAuctionListing2.seller, address(0x04), "seller not correctly set");
        assertEq(testAuctionListing2.name, "David's 3rd Dish", "Goleta, CA");
        assertEq(testAuctionListing2.currWinner, address(0x00), "winner not correctly initalized");
        assertEq(testAuctionListing2.isActive, true, "not set as active");
        assertEq(testAuctionListing2.isShippable, false, "isShippable not correctly set");
        assertEq(testAuctionListing2.location, "Goleta, CA", "location not correctly set");

    }

    // multi-stock and restock
    function testBuyAndStock() public {
        Listings.Listing[] memory testListings = listings.getListings();

        assertEq(testListings[1].stockRemaining, 3, "Cars start less than 3");
        
        deal(alice, 15 ether);

        // alice buys 2 cars
        vm.startPrank(alice);
        assertEq(listings.buyListing{value: 5 ether}(1), true, "Buying unsuccessful.");
        assertEq(listings.buyListing{value: 5 ether}(1), true, "Buying unsuccessful.");
        vm.expectRevert("Only the seller can change stock.");
        listings.restockListing(1, 3);
        vm.stopPrank();

        testListings = listings.getListings();
        assertEq(alice.balance, 5 ether, "Alice didn't lose balance");
        assertEq(charlie.balance, 10 ether, "Charlie didn't receive payment");
        assertEq(testListings[1].stockRemaining, 1, "Did not correctly buy 2 cars");

        vm.startPrank(charlie);
        listings.restockListing(1, 3);
        vm.stopPrank();

        testListings = listings.getListings();
        assertEq(testListings[1].stockRemaining, 3, "Restock not successful");
    }

    // bid as Alice and Bob
    function testAuctionBidding() public {
        Listings.AuctionListing memory testAuctionListing = listings.getAuctionListings()[0];

        assertEq(testAuctionListing.currWinner, address(0x00), "A winner is set");

        deal(alice, 10 ether);
        deal(bob, 5 ether);
        
        vm.startPrank(alice);
        assertEq(listings.placeBid{value: 1 ether}(0), true, "Bidding failed");
        vm.stopPrank();

        testAuctionListing = listings.getAuctionListings()[0];
        assertEq(testAuctionListing.currWinner, alice, "Alice is not the current winner");
        assertEq(alice.balance, 9 ether, "Alice doesn't have the correct amount of ether");

        vm.startPrank(bob);
        assertEq(listings.placeBid{value: 5 ether}(0), true, "Bidding failed");
        vm.stopPrank();

        testAuctionListing = listings.getAuctionListings()[0];
        assertEq(testAuctionListing.currWinner, bob, "Bob is not the current winner");
        assertEq(alice.balance, 10 ether, "Alice doesn't have the correct amount of ether");
        assertEq(bob.balance, 0, "Bob doesn't have the correct amount of ether");

        vm.startPrank(alice);
        assertEq(listings.placeBid{value: 10 ether}(0), true, "Bidding failed");
        vm.stopPrank();

        testAuctionListing = listings.getAuctionListings()[0];
        assertEq(testAuctionListing.currWinner, alice, "Alice is not the current winner");
        assertEq(alice.balance, 0, "Alice doesn't have the correct amount of ether");
        assertEq(bob.balance, 5 ether, "Bob doesn't have the correct amount of ether");

        vm.startPrank(david);
        listings.endAuction(0);
        vm.stopPrank();

        testAuctionListing = listings.getAuctionListings()[0];
        assertEq(testAuctionListing.isActive, false, "Auction still active");
        assertEq(david.balance, 10 ether, "David didn't receive payment");

    }

    // reentracy protection tests
    function testReentracyProtection() public {
        TestBuyAccount attacker1 = new TestBuyAccount();
        TestAuctionAccount attacker2 = new TestAuctionAccount();
        address attacker3 = address(0x05);

        deal(attacker3, 1000 ether);

        // purchase reentracy
        vm.startPrank(address(attacker1));
        
        vm.stopPrank();

        vm.startPrank(attacker3);

        vm.stopPrank();

    }
}