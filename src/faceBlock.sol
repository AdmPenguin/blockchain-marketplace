// to do: users should be able to create an account, login, logout, add an Item to their virtual wallet, view all open listings, create a listing, buy a listing, 
//    rate someone they bought from once, get the ratings of users, add to their balance, check their balance, see what items they have(not really possible, users need create instances of a seperate contract to so so)

pragma solidity ^0.8.13;

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";
import { Listings } from "../src/Listings.sol";

contract MarketPlace{

    Items private itemManager;
    Users private userManager;
    Listings private listingsManager;

    constructor() {
        userManager = new Users();
        itemManager = new Items(userManager);
        listingsManager = new Listings(itemManager, userManager);
    }

    
    mapping(address => bool) private loggedIn;

    //use for functions that require users to be logged in to call
    modifier loginNecessary(){
        require(loggedIn[msg.sender] == true, "must be logged in to use this function");
        _;
    }

    function createAccount(string calldata _username, string calldata _password) public {
        userManager.registerUser(_username, _password, msg.sender);
    }

    function login(string calldata _username, string calldata _password) public{
        require(loggedIn[msg.sender] == false, "already logged in");
        require(userManager.authenticateUser(_username, _password, msg.sender) == true, "Login failed, wrong username and password");
        loggedIn[msg.sender] = true;
    }

    function logout() public view loginNecessary() {
        loggedIn[msg.sender] == false;
    }

    // creates a virtual representation of an item that they would like to put on the marketplace
        //ideally users would have to submit a unique identifier of the item to prove it exists and is not already created but this is not implemented here
    function createItem(string memory _name) public loginNecessary(){
        itemManager.createItem(_name, msg.sender);
    }

    function getLast25OpenListings() public view loginNecessary() returns(uint[25] memory){
        return listingsManager.getLast25OpenListings();
    }

    function getItemOwner(uint itemId) public view returns(string memory){
        return itemManager.getItemOwner(itemId);
    }
    
    function createListing(string calldata name, uint256 _minPrice, uint _itemId, uint40  biddingDurationDays, bool isShippable, string calldata location)public loginNecessary(){
        listingsManager.createListing(_minPrice, name, _itemId, biddingDurationDays, isShippable, location, msg.sender);
    }

    //returns true if bid was successful and reverts otherwise
        //if bid fails money is returned to user
    function bidOnListing(uint listingId) external payable loginNecessary() returns(bool){
        (bool success, ) = address(listingsManager).call{value: msg.value}(abi.encodeWithSignature("bidOnListing(uint256,address)", listingId, msg.sender));
        require(success, "Bid Failed");
        return true;
    }

    function endListingAsSeller(uint listingId) public loginNecessary(){
        listingsManager.sellerEndBidding(listingId, msg.sender);
    }

    function endListingAsWinningBidder(uint listingId) public loginNecessary(){
        listingsManager.highestBidderEndBiddingPostBiddingPeriod(listingId, msg.sender);
    }

    function rateSellerAsWinnerOfListing(uint listingId, uint rating) public loginNecessary(){
        listingsManager.rateSellerOfListingYouWon(listingId, rating, msg.sender);
    }

    function getMinBidPriceForListing(uint listingId) public view returns(uint){
        return listingsManager.getMinPriceForListing(listingId);
    }

    function getSecondsBeforeBiddingEndsForListing(uint listingId) public view returns(uint){
        return listingsManager.getSecondsBeforeBiddingEndsForListing(listingId);
    }

    function getRatingOfListingSeller(uint listingId) public view returns(uint){
        return listingsManager.getRatingOfListingSeller(listingId);
    }

    function getNumberOfRatingOfListingSeller(uint listingId) public view returns(uint){
        return listingsManager.getNumberOfRatingOfListingSeller(listingId);
    }

}
