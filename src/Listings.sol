// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Users} from "../src/Users.sol";
import { Wallet } from "../src/Wallet.sol";

contract Listings {
    // Standard listing (stocked, single price)
    struct Listing {
        uint256 id;
        uint256 price;
        address seller;
        string name;
        uint40 stockRemaining;

        // if is not shippable, location is where it is sold from. if is, where shipping from
        // can be 'N/A'
        bool isShippable;
        string location;

    }

    // Auction Listing (only one in stock)
    struct AuctionListing {
        uint256 id;
        uint256 price;
        address seller;
        address currWinner;

        // if is not shippable, location is where it is sold from. if is, where shipping from
        bool isShippable;
        string location;
    }

    Listing[] private listings;
    AuctionListing[] private auctionListing;

    mapping(uint256 => Listing) private idToListing;

    constructor() {
        Listing memory listing = Listing({
            id: 0,
            price: 0,
            seller: address(0),
            name: "UNTITLED LISTING",
            stockRemaining: 0,
            isShippable: false,
            location: "N/A"
        });
        listings.push(listing);
    }

    function createListing(uint256 amount, string calldata name, uint40 stockRemaining, bool isShippable, string calldata location) public returns (bool){
        Listing memory listing = Listing({
            id: 0, // TODO: Randomize IDs
            price: amount,
            seller: msg.sender,
            name: name,
            stockRemaining: stockRemaining,
            isShippable: isShippable,
            location: location
        });
        listings.push(listing);

        return true;
    }

    // takes in  a listing id and amount, and sets the amount on that listing to be the same
    function restockListing(uint256 id, uint40 amount) public{
        Listing memory listing = idToListing[id];
        listing.stockRemaining = amount;
    }

    // takes in a listing id, and attempts to buy it with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    function buyListing(uint256 id) public returns (bool){
        Listing memory listingToBuy = idToListing[id];
        if(listingToBuy.stockRemaining)
        return false;
    }

    // takes in a listing id, and attempts to place a bid with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    function placeBid(uint256 id, uint256 amount) public returns (bool){
        AuctionListing memory listingToBid = idToListing[id];

        if(amount > listingToBid.price){
            listingToBid.price = amount;
            listingToBid.currWinner = msg.sender;
            return true;
        }
        else {
            return false;
        }

    }

    // takes in string regex and returns an array of listings with the same name
    function getListings(string calldata regex) public returns(Listing[] memory){
        Listing[] memory listings;

        return listings;

    }

    // takes in string regex and returns an array of auction listings with the same name
    function getAuctionListings(string calldata regex) public returns(AuctionListing[] memory){
        AuctionListing[] memory listings;

        return listings;

    }

}
