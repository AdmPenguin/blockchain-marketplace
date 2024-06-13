// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";

contract Listings {

    Items private itemManager;
    Users private userManager;

    // Standard listing (stocked, single price)
    struct Listing {
        uint256 listingId;
        uint256 price;
        address seller;
        string name;
        uint itemId;
        bool forSale;

        // if is not shippable, location is where it is sold from. if is, where shipping from
        // can be 'N/A'
        bool isShippable;
        string location;
    }

    // Auction Listing (only one in stock)
    struct AuctionListing {
        uint256 listingId;
        uint itemId;
        uint256 price;
        string name;
        address seller;
        address currWinner;
        bool openForBidding;


        // if is not shippable, location is where it is sold from. if is, where shipping from
        bool isShippable;
        string location;
    }

    uint public nextListingId = 0;
    uint public nextAuctionListingId = 0;

    Listing[] private listings;
    AuctionListing[] private auctionListing;

    Listing[] listings;
    AuctionListing[] auctionListings;


    mapping(address => bool) private paymentLock; // locks paying to prevent reentrancy attacks

    constructor(Items _itemManager, Users _userManager) {
        itemManager = _itemManager;
        userManager = _userManager;
    }

    function createListing(uint256 _price, string calldata name, uint _itemId, bool isShippable, string calldata location) public returns (bool){
        itemManager.transferItem(_itemId, address(this));
        Listing memory listing = Listing({
            listingId: nextListingId, 
            price: _price,
            seller: msg.sender,
            name: name,
            itemId: _itemId,
            forSale: true,
            isShippable: isShippable,
            location: location
        });

        nextListingId++;
        listings.push(listing);
    }

    // creates a new auction listing with the following parameters
    function createAuctionListing(uint256 startingPrice, string calldata name, bool isShippable, string calldata location) public {
        AuctionListing memory listing = AuctionListing({
            id: auctionListings.length,
            price: startingPrice,
            seller: msg.sender,
            name: name,
            currWinner: address(0x00),
            isActive: true,
            isShippable: isShippable,
            location: location
        });
        auctionListings.push(listing);
    }

    // allows seller to end their auction and collect payment
    // returns true if successful, false if not
    function endAuction(uint256 id) public{
        if(id >= auctionListings.length){
            revert("Invalid ID");
        }

        AuctionListing memory listing = auctionListings[id];

        if(listing.isActive == true){
            auctionListings[id].isActive = false;
            msg.sender.call{value: listing.price}("");
        }
        else {
            revert("Only the seller can end the auction.");
        }

    }

    // takes in a listing id, and attempts to buy it with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    function buyListing(uint256 listingId) public returns (bool){
        Listing memory listingToBuy = idToListing[listingId];
        require(listingToBuy.forSale, "Listing not for sale");
        require(userManager.transferMoney(listingToBuy.price, listingToBuy.seller), "Transaction failed");

        idToListing[listingId].forSale = false;
        itemManager.transferItem(listingToBuy.itemId, msg.sender);
        return true;     
    }

    // takes in a listing id, and attempts to place a bid with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    // function placeBid(uint256 listingId, uint256 amount) public returns (bool){
    //     AuctionListing memory listingToBid = idToListing[listingId];

    //     if(amount > listingToBid.price){
    //         listingToBid.price = amount;
    //         listingToBid.currWinner = msg.sender;
    //         return true;
    //     }
    //     else {
    //         return false;
    //     }

    // }

    // // takes in string regex and returns an array of listings with the same name
    // function getListings(string calldata regex) public returns(Listing[] memory){
    //     Listing[] memory listings;

    //     return listings;

    // }

    // // takes in string regex and returns an array of auction listings with the same name
    // function getAuctionListings(string calldata regex) public returns(AuctionListing[] memory){
    //     AuctionListing[] memory listings;

    //     return listings;

    // }

}
