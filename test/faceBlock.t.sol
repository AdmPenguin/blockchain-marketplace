// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {MarketPlace} from "../src/faceBlock.sol";

contract faceBlockTest is Test{
    MarketPlace public faceblockContract;
    address testUser1 = address(0x01);
    address testUser2 = address(0x02);
    address testUser3 = address(0x03);
    address testSeller1 = address(0x04);
    address testSeller2 = address(0x05);

    uint shirtListing;
    uint shirtItem;

    function setUp() public {
        faceblockContract = new MarketPlace();
        deal(address(testUser1), 1000 ether);
        deal(address(testUser2), 1000 ether);
        deal(address(testUser3), 1000 ether);
        deal(address(testSeller1), 1000 ether);
        deal(address(testSeller2), 1000 ether);
    }

    function test_new_user_experience() public {
        
        vm.startPrank(testSeller1);
        
        //user first trys to login but does have account
        try faceblockContract.login("clothesSeller", "ILikeClothes"){
            assertEq(true, false);
        } 
        catch Error(string memory reason){
            assertEq(reason, "User not registered");
        }

        //user creates an account and logs in

        faceblockContract.createAccount("clothesSeller", "ILikeClothes");

            //user should now have an registered account
        try faceblockContract.createAccount("clothesSeller", "ILikeClothes"){
            assertEq(true, false);
        }
        catch Error(string memory reason){
            assertEq(reason, "User already registered");
        }

            // user needs to login before using certain functions
        try faceblockContract.createItem("my shirt"){
            assertEq(true, false);
        }
        catch Error(string memory reason){
            assertEq(reason, "Must be logged in to use this function");
        }

        
        faceblockContract.login("clothesSeller", "ILikeClothes");
        uint shirtId = faceblockContract.createItem("my shirt");
        shirtItem = shirtId;
        assertEq(faceblockContract.getItemOwner(shirtId), "clothesSeller");

        uint shirtListingId = faceblockContract.createListing("a listing for my shirt", 1 ether, shirtId, 1, true, "Tahllahase");
        shirtListing = shirtListingId;

        assertEq(faceblockContract.getLast25OpenListings()[0], shirtListingId);

        vm.stopPrank();
    }

    function setUpPart2() public{
        vm.startPrank(testUser1);
        faceblockContract.createAccount("iWannaBuyAShirt", "ilikeshirts");
        faceblockContract.login("iWannaBuyAShirt", "ilikeshirts");
        vm.stopPrank();

        vm.startPrank(testUser2);
        faceblockContract.createAccount("iWannaBuyAShirtMore", "ireallylikeshirts");
        faceblockContract.login("iWannaBuyAShirtMore", "ireallylikeshirts");
        vm.stopPrank();

    }

    function test_bidding() public{
        test_new_user_experience();
        setUpPart2();

        //user1 checks how much he has to pay for the shirt and bids that much
        vm.startPrank(testUser1);
        assertEq(faceblockContract.getMinBidPriceForListing(shirtListing), 1 ether);
        faceblockContract.bidOnListing{value: 2 ether}(shirtListing);
        assertEq(faceblockContract.getMinBidPriceForListing(shirtListing), 2 ether);
        vm.stopPrank();

        //user2 does the same and bids one more than user1
        vm.startPrank(testUser2);
        assertEq(faceblockContract.getMinBidPriceForListing(shirtListing), 2 ether);
        faceblockContract.bidOnListing{value: 3 ether}(shirtListing);
        assertEq(faceblockContract.getMinBidPriceForListing(shirtListing), 3 ether);
        vm.stopPrank();

        //user1 should have got his bid refunded
        assertEq(address(testUser1).balance, 1000 ether);
        
        //seller ends bidding
        vm.startPrank(testSeller1);
        faceblockContract.endListingAsSeller(shirtListing);
        assertEq(faceblockContract.getItemOwner(shirtItem), "iWannaBuyAShirtMore");
        vm.stopPrank();
        assertEq(address(testSeller1).balance, 1003 ether);
    }
}