// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// This tests reentrancy attacks, which would allow an attacker to drain the contract of funds
// If this test fails, the contract can be drained by either a bidder, a seller, or a combination of both working together

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import { MarketPlace } from "../src/faceBlock.sol";

contract Attacker {
    MarketPlace public marketplace;
    uint count;

    constructor(MarketPlace _marketPlace) {
        marketplace = _marketPlace;
        count = 0;
    }

    fallback() payable external {
        if(count == 0){
            console.log("TEST");
            marketplace.endListingAsSeller(0);
            count++;
        }
    }

}

contract ReentrancyTest is Test {
    MarketPlace public marketplace;

    Attacker attacker;

    function setUp() public {
        marketplace = new MarketPlace();
        attacker = new  Attacker(marketplace);

        deal(address(marketplace), 100 ether);
        deal(address(attacker), 1 ether);
        
        vm.startPrank(address(attacker));
        marketplace.createAccount("alice", "password");
        marketplace.login("alice", "password");
        marketplace.createItem("Test Item");
        marketplace.createListing("Test Listing", 1 ether, 0, 1, true, "Goleta, CA");
        vm.stopPrank();

    }

    function testSellerEndListing() public {
        vm.startPrank(address(attacker));
        marketplace.endListingAsSeller(0);
        vm.stopPrank();

        assertEq(address(marketplace).balance, 100 ether);
    }


}