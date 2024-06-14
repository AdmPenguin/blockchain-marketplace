// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Users } from "../src/Users.sol";
import { Items } from "../src/Items.sol";

contract Listings {

    Items private itemManager;
    Users private userManager;

    // Standard listing (stocked, single price)
    
    struct Listing {
        string name;
        uint256 listingId;
        uint itemId;
        
        bool forSale;        
        uint256 minPrice;
        address seller;
        address highestBidder;
        uint endOfBidding;

        // if is not shippable, location is where it is sold from. if is, where shipping from
        bool isShippable;
        string location;

    }


    uint public nextListingId = 0;
    uint public numberOfOpenListings = 0;
    
    mapping(uint256 => Listing) private idToListing;

    mapping(uint => mapping(address => uint)) private listingIdToOwedBalances;

    constructor(Items _itemManager, Users _userManager) {
        itemManager = _itemManager;
        userManager = _userManager;
        userManager.registerUser("Amazon", "Bezos", address(this));
    }

    function createListing(uint _minPrice, string calldata name, uint _itemId, uint40  biddingDurationDays, bool isShippable, string calldata location, address caller) public returns(uint){
        //restrict bidding duration so that people cannot create listings that can last forever(keeps people from causing buyers money to be locked up indefinitely)
        require(biddingDurationDays >= 1, "Listings must be up for at least 1 day");
        require(biddingDurationDays < 30, "Max Bidding Duration is 30 Days");
        
        // listing contract owns item while the listing is up
        itemManager.transferItem(_itemId, address(this), caller);

        Listing memory listing = Listing({
            listingId: nextListingId, 
            minPrice: _minPrice,
            seller: caller,
            name: name,
            itemId: _itemId,
            forSale: true,
            isShippable: isShippable,
            location: location,
            highestBidder: caller,
            endOfBidding: block.timestamp + biddingDurationDays*86400 // 1 day is 86400 sec
        });

        idToListing[nextListingId] = listing;
        nextListingId++;
        
        
        numberOfOpenListings++;

        return listing.listingId;
    }

    // allows seller to end their auction and collect payment
    // returns true if successful, false if not
    function endAuction(uint256 id) public{
        if(id >= auctionListings.length){
            revert("Invalid ID");
        }
    }


    function bidOnListing(uint listingId, address caller) external payable returns(bool){
        require(listingId < nextListingId, "Listing does not exitst");


        // prevent seller from bidding on their own listing
        require(idToListing[listingId].seller != caller, "seller cannot bid on their own product");

        //Listing must be for sale to purchase, and bid must be higher than previous maximum bid
        Listing memory listingToBuy = idToListing[listingId];
        require(listingToBuy.forSale == true, "Listing not for sale");
        require(msg.value > listingToBuy.minPrice, "Bid lower than minimum price needed to be top bidder");

        // Bids can only be made before end of bidding
        require(block.timestamp < listingToBuy.endOfBidding, "bidding period has ended for this listing"); 

        //return previous highest bidder's money
        //if no one has bid yet then nothing will be returned to the seller
        //tracking what is owed to previous highest bidders just in case for some reason the contract fails to return ether to previous highest bidder
                //more of a future consideration and attack prevention
        if (listingToBuy.highestBidder != listingToBuy.seller){
            uint bal = listingIdToOwedBalances[listingId][listingToBuy.highestBidder];
            (bool r, ) = listingToBuy.highestBidder.call{value: bal}("");
            if(r){
                listingIdToOwedBalances[listingId][listingToBuy.highestBidder] = 0;
            }
        }
       

        
        // store how much is owed to the user, in the case that someone outbids them so they can get their money back
        listingIdToOwedBalances[listingId][caller] = msg.value;
        
        // new min price represents highest bid, bidder becomes new highest bidder
        idToListing[listingId].minPrice = msg.value;
        idToListing[listingId].highestBidder = caller;

        return true;
    }

    function sellerEndBidding(uint listingId, address caller) public{
        require(listingId < nextListingId, "Listing does not exitst");
        // enables seller to end bidding early if they want to accept the current highest offer
        require(caller == idToListing[listingId].seller, "Only seller can end bidding before the end of bidding duration");

        require(idToListing[listingId].forSale == true, "bidding has already ended");

        Listing memory listingToEnd = idToListing[listingId];

        // Item gets transferred to highest bidder, if no valid bids it is returned to the seller
        itemManager.transferItem(listingToEnd.itemId, listingToEnd.highestBidder, address(this));

        //seller gets the eth that the highest bidder, bid
        //Balance owed to highestbidder gets set to 0 (they bought the item)
        if (listingToEnd.highestBidder != listingToEnd.seller){
            uint bal = listingIdToOwedBalances[listingId][listingToEnd.highestBidder];
            (bool r, ) = listingToEnd.seller.call{value: bal}("");
            listingIdToOwedBalances[listingId][listingToEnd.highestBidder] = 0;
            
        }
        
        //Listing Marked as no longer for sale
        idToListing[listingId].forSale = false;
        numberOfOpenListings--;
    }

    //allow the highest bidder to end bidding and claim their item if the seller hasn't ended the bidding by the end of the bidding duration
        //prevents bidders from not ending the bidding and keeping the highest bidders eth locked up in the contract
    function highestBidderEndBiddingPostBiddingPeriod(uint listingId, address caller) public {
        require(listingId < nextListingId, "Listing does not exitst");
        Listing memory listingToEnd =  idToListing[listingId];
        require(listingToEnd.highestBidder == caller, "Only the highest bidder can end the listing using this function");
        require(block.timestamp >= listingToEnd.endOfBidding, "Bidders cannot end end bidding before the bidding period has ended");
        require(idToListing[listingId].forSale == true, "Bidding has already been ended");

        // Item gets transferred to highest bidder, if no valid bids it is returned to the seller
        itemManager.transferItem(listingToEnd.itemId, listingToEnd.highestBidder, address(this));

        //seller gets the eth that the highest bidder, bid
        //Balance owed to highestbidder gets set to 0 (they bought the item)
        if (listingToEnd.highestBidder != listingToEnd.seller){
            uint bal = listingIdToOwedBalances[listingId][listingToEnd.highestBidder];
            (bool r, ) = listingToEnd.seller.call{value: bal}("");
            listingIdToOwedBalances[listingId][listingToEnd.highestBidder] = 0;
            
        }
        
        //Listing Marked as no longer for sale
        idToListing[listingId].forSale = false;
        numberOfOpenListings--;

    }

    function rateSellerOfListingYouWon(uint listingId, uint rating, address caller)  public {
        require(listingId < nextListingId, "Listing does not exitst");
        
        Listing memory listingToRate = idToListing[listingId];
        require(listingToRate.forSale == false, "Cannot rate a seller based on a listing before a listing is finalized");
        require(listingToRate.highestBidder == caller, "Must be the winner of the listing to rate seller");
        require(listingToRate.highestBidder != listingToRate.seller, "Sellers cannot rate themselves");

        userManager.submitRating(listingToRate.seller, rating, caller);

        //this is so once a seller has been rating for a particular listing no one can rate him again
        idToListing[listingId].highestBidder = address(0);
        
    }

// functions to get listing information

    // Solidity doesn't allow for dynamic arrays in function calls, this is work around however the number of open listings you can get has to be constant
        // In reality if this was ever deployed events would be emmitted when listing status changes allowing for the front end of this market place to track listing, information
    function getLast25OpenListings() public view returns(uint[25] memory){
        
        uint[25] memory openListingIds;
        uint openListingCounter = 0;
        for (uint i = 0; i <  nextListingId && openListingCounter < 25; i++){
            if(idToListing[i].forSale == true){
                openListingIds[openListingCounter] = idToListing[i].listingId;
            }
        }

        return openListingIds;
    }
    //returns highest bid on a listing
    function getMinPriceForListing(uint listingId) public view returns(uint){
        require(listingId < nextListingId, "Listing does not exitst");
        return idToListing[listingId].minPrice;
    }

    //returns seconds left before bidding ends - front end can change to days, hours, etc 
    //returns 0 if bidding has ended
    function getSecondsBeforeBiddingEndsForListing(uint listingId) public view returns(uint){
        require(listingId < nextListingId, "Listing does not exitst");
        if(block.timestamp > idToListing[listingId].endOfBidding){
            return 0;
        }

        return idToListing[listingId].endOfBidding - block.timestamp;
    }
    
   
OfListingSeller(uint listingId) public view returns(uint){
        require(listingId < nextListingId, "Listing does not exitst");
        Listing memory listing = idToListing[listingId];
        return userManager.getAverageRating(listing.seller);
    }

    function getNumberOfRatingOfListingSeller(uint listingId) public view returns(uint){
        require(listingId < nextListingId, "Listing does not exitst");
        Listing memory listing = idToListing[listingId];
        return userManager.getNumberOfRatings(listing.seller);
    }

}
