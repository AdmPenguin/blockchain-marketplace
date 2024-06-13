// to do: users should be able to create an account, login, logout, add an Item to their virtual wallet, view all open listings, create a listing, buy a listing, 
//    rate someone they bought from once, get the ratings of users, add to their balance, check their balance, see what items they have

pragma solidity ^0.8.13;

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";

contract MarketPlace {

    Items private itemManager;
    Users private userManager;
    Listings private listingsManager;

    constructor() {
        userManager = new Users();
        itemManager = new Items(userManager);
        listingsManager = new Listings(itemManager, userManager);
    }

    
    mapping(address => bool) private loggedIn;

    modifier loginNecessary(){
        require(loggedIn[msg.sender] == true);
        _;
    }

    function createAccount(string calldata _username, string calldata _password) public {
        userManager.registerUser(_username, _password);
    }

    function login(string calldata _username, string calldata _password) public{
        require(loggedIn[msg.sender] == false, "already logged in");
        require(userManager.authenticateUser(_username, _password) == true, "login failed");
        loggedIn[msg.sender] = true;
    }

    function logout() public view loginNecessary() {
        loggedIn[msg.sender] == false;
    }

    function createListing(string calldata itemName, string calldata listingName)

}
