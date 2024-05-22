// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Listings {
    // Standard listing (stocked, single price)
    struct Listing {
        uint256 id;
        uint256 price;
        address seller;
        string name;
        uint40 stockRemaining;

        // if is not shippable, location is where it is sold from. if is, where shipping from
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

}
