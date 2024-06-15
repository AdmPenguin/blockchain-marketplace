// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {Users} from "../src/Users.sol";

contract UsersTest is Test {
    Users public userManager;

    address alice = address(0x01);
    address bob = address(0x02);
    address charlie = address(0x03);
    
    function setUp() public {
        userManager = new Users();

        userManager.registerUser("alice", "password", alice);
        userManager.registerUser("bob", "password", bob);
    }

    function testRegisterUser() public {
        assertEq(userManager.registeredUsers(alice), true);
        assertEq(userManager.registeredUsers(bob), true);
        vm.expectRevert("User already registered");
        userManager.registerUser("alice", "password", alice);
    }

    function testAuthenicateUser() public {
        assertEq(userManager.authenticateUser("alice", "password", alice), true);
        assertEq(userManager.authenticateUser("alice", "incorrect", alice), false);
        vm.expectRevert("User not registered");
        userManager.authenticateUser("charlie", "password", charlie);
    }

    function testSubmitRating() public {
        userManager.submitRating(alice, 5, bob);
        assertEq(userManager.getAverageRating(alice), 500);
        assertEq(userManager.getNumberOfRatings(alice), 1);

        vm.expectRevert("Rating must be between 0 and 5 stars");
        userManager.submitRating(alice, 100, bob);

        vm.expectRevert("Users cannot rate themselves");
        userManager.submitRating(alice, 5, alice);

    }

}