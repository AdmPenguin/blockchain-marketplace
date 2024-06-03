// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Users } from "../src/Users.sol";
// import { Wallet } from "../src/Wallet.sol";

contract Listings {
    // Standard listing (stocked, single price)
    struct Listing {
        uint256 id;
        uint256 price;
        address seller;
        string name;
        uint40 stockRemaining; // stockRemaining == 0 for inactive

        // if is not shippable, location is where it is sold from. if is, where shipping from
        // can be 'N/A'
        bool isShippable;
        string location;

    }

    // Auction Listing (only one in stock)
    struct AuctionListing {
        uint256 id;
        uint256 price;
        string name;
        address seller;
        address currWinner;
        bool isActive;

        // if is not shippable, location is where it is sold from. if is, where shipping from
        bool isShippable;
        string location;
    }

    Listing[] listings;
    AuctionListing[] auctionListings;

    mapping(address => bool) private paymentLock; // locks paying to prevent reentrancy attacks

    // this is a test function
    // when users is added, will be set there instead
    function setPaymentLock(address addressToSet) public {
        if(msg.sender == address(0x69)){
            paymentLock[addressToSet] = false;
        }
    }

    // creates a new listing with the following parameters
    function createListing(uint256 amount, string calldata name, uint40 stockRemaining, bool isShippable, string calldata location) public {
        Listing memory listing = Listing({
            id: listings.length,
            price: amount,
            seller: msg.sender,
            name: name,
            stockRemaining: stockRemaining,
            isShippable: isShippable,
            location: location
        });
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

    // takes in  a listing id and amount, and sets the amount on that listing to be the same
    function restockListing(uint256 id, uint40 amount) public {
        if(id >= listings.length){
            revert("Invalid ID");
        }

        Listing memory listing = listings[id];

        if(msg.sender == listing.seller){
            listings[id].stockRemaining = amount;
        }
        else {
            revert("Only the seller can change stock.");
        }
    }

    // takes in a listing id, and attempts to buy it with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    function buyListing(uint256 id) payable public returns (bool){
        if(id >= listings.length){
            return false;
        }

        Listing storage listingToBuy = listings[id];

        if(listingToBuy.stockRemaining <= 0){
            msg.sender.call{value: msg.value}("");
            return false;
        }

        if(msg.value == listingToBuy.price){
            if(paymentLock[listingToBuy.seller] == false){
                paymentLock[listingToBuy.seller] = true;

                listingToBuy.seller.call{value: msg.value}("");
                listingToBuy.stockRemaining--;

                paymentLock[listingToBuy.seller] = false;

                return true;
            }
            else {
                msg.sender.call{value: msg.value}("");
                return false;
            }
        }
        else {
            msg.sender.call{value: msg.value}("");
            return false;
        }
    }

    // takes in a listing id, and attempts to place a bid with the current user balance
    // returns true if successful, false otherwise (e.g. balance too low)
    function placeBid(uint256 id) payable public returns (bool){
        if(id >= auctionListings.length){
            return false;
        }

        AuctionListing storage listingToBid = auctionListings[id];
        
        if(listingToBid.isActive == false){
            msg.sender.call{value: msg.value}("");
            return false;
        }

        if(msg.value > listingToBid.price){
            // return money from previous winner
            if(paymentLock[listingToBid.currWinner] == false){
                paymentLock[listingToBid.currWinner] = true;
                listingToBid.currWinner.call{value: listingToBid.price}("");
                paymentLock[listingToBid.currWinner] = false;
            }

            // set new winning bid
            listingToBid.currWinner = msg.sender;
            listingToBid.price = msg.value;
            return true;
        }
        else {
            msg.sender.call{value: msg.value}("");
            return false;
        }

    }

    // takes in string regex and returns an array of listings with the same name
    function getListings() view public returns(Listing[] memory){
        return listings;
    }

    // takes in string regex and returns an array of auction listings with the same name
    function getAuctionListings() view public returns(AuctionListing[] memory){
        return auctionListings;
    }

}
