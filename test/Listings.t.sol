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

    address testBuyer = address(0x01);
    address testSeller = address(0x02);

    function setUp() public {
        usersContract = new Users();
        itemsContract = new Items(usersContract);
        listingsContract = new Listings(itemsContract, usersContract);

        vm.startPrank(testBuyer);
        usersContract.registerUser("buyer", "password");
        vm.stopPrank();

        vm.startPrank(testSeller);
        usersContract.registerUser("seller", "password");
        vm.stopPrank();
    }   

    function test_itemTransfer() public {
        vm.startPrank(testSeller);
        uint testItemId = itemsContract.createItem("my house");
        assertEq(itemsContract.getItemOwner(testItemId), testSeller);
        itemsContract.transferItem(testItemId, testBuyer);
        assertEq(itemsContract.getItemOwner(testItemId), testBuyer);
        vm.stopPrank();
    }


    
}
