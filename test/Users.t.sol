// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {Users} from "../src/Users.sol";

contract UsersTest is Test {
    Users public usersContract;


    address testUser = address(0x01);
    address rater = address(0x02);
    


    function setUp() public {   
        usersContract = new Users();
    }

    function setup_accounts() public {
        vm.startPrank(testUser);
        usersContract.registerUser("user1", "password");
        vm.stopPrank();
    }

    

    // ========================== //
    // ==== local test cases ==== //
    // ========================== //

    // verify user

    function test_authenticate_user() public {
        vm.startPrank(testUser);
        usersContract.registerUser("user1", "password");
        assertEq(usersContract.authenticateUser("user1", "password"), true);
        assertEq(usersContract.authenticateUser("user1", "not_password"), false);
        vm.stopPrank();
    }

    // get rating when no ratings
    function test_getAverageRating_when_no_ratings() public {
        vm.startPrank(testUser);
        try usersContract.getAverageRating(msg.sender){
            assertEq(true, false);
        } catch Error(string memory reason){
            assertEq(reason, "User not registered");
        }
        vm.stopPrank();
    }

    function test_getNumberOfRatings_when_no_ratings() public {
        vm.startPrank(testUser);
        usersContract.registerUser("user1", "password");
        try usersContract.getNumberOfRatings(msg.sender){
            assertEq(true, false);
        } catch Error(string memory reason){
            assertEq(reason, "User not registered");
        }
        vm.stopPrank();
    }

    function test_getAvgRating_getNumberOfRatings() public {
        vm.startPrank(testUser);
        usersContract.registerUser("user1", "password");
        vm.stopPrank();

        vm.startPrank(rater);
        usersContract.submitRating(testUser, 5);
        assertEq(usersContract.getNumberOfRatings(testUser), 1);
        assertEq(usersContract.getAverageRating(testUser), 500);
        vm.stopPrank();
    }

}