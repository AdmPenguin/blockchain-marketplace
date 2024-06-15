// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {Users} from "../src/Users.sol";
import {Items} from "../src/Items.sol";

contract ItemsTest is Test {
    Users public userManager;
    Items public itemsManager;

    address alice = address(0x01);
    address bob = address(0x02);

    function setUp() public{
        userManager = new Users();
        itemsManager = new Items(userManager);

        userManager.registerUser("alice", "password", alice);
        userManager.registerUser("bob", "password", bob);
    }

    function testCreateItem() public {
        itemsManager.createItem("Alice's Car", alice);
        assertEq(itemsManager.getItemOwner(0), "alice");
    }

    function testTransferItem() public {
        itemsManager.createItem("Alice's Car", alice);
        assertEq(itemsManager.getItemOwner(0), "alice");
        itemsManager.transferItem(0, bob, alice);
        assertEq(itemsManager.getItemOwner(0), "bob");
        
    }

}