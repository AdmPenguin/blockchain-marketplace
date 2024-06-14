# FaceBlock Marketplace
### By Alexander Thomas, Amgad Hawari, Bao Tran
An eth-based marketplace backend

## Introduction
FaceBlock Marketplace is a peer-to-peer etherium based marketplace smart contract designed to serve as a backend to manage users, items, listings, and auctions.

## Running
FaceBlock Marketplace is designed to be a backend, and therefore should be imported into another smart contract which handles UI and user input. It, by itself, cannot faciliate user interaction.

## Subcontracts & Functions

### Users
The Users contract allows for users to register, which is a requirement to participate on the marketplace, and stores rating information about a specific user.

- registerUser: Registers a new user tied to address [caller] with username [username] and passwordHash of the SHA256 of [_password]
- authenicateUser: Takes a [_username] and [_password] and will let the user login if they are correct for the address [_caller]
- getUsername: Returns the username of the user with address [addressOfUser]
- submitRating: Submits a [rating] between [0, 5] for user with address [userAddress]
- getAverageRating: Returns the average rating of the user with address [userAddress]
- getNumberOfRatings: Returns how many ratings the user with address [useraddress] has received

### Items
- createItem: Creates an item with [_name], owned by [caller]
- transferItem: Transfers item with id [_itemdId] from [caller] to [_to]
- getItemOwner: Returns the address of the owner of item with item id [_itemId]


### Listings
The Listings contract allows for sellers to list their items on FaceBlock by creating a listing for it.

- createListing: Function which takes the arguments provided and creates a new listing based on said arguments. We limit bidding to be [1, 30) days.
- bidOnListing: Takes a listing ID and attempts to bid on it. If the bid is greater than the amount, the bidder becomes the new highest bidder.
- sellerEndBidding: Allows the seller to end an auction with id [listingId].
- highestBidderEndBiddingPostBiddingPeriod: Allows the current highest bidder to end the auction if the auction period has been exceeded w/o the seller ending it.
- rateSellerOfListingYouWon: Allows a buyer to rate the seller after they have won between 0 and 5, inclusive
- getLast25OpenListing: Returns the last 25 open listings
- getMinPriceForListing: Returns the minPrice for the listing with id [listingId]
- getNumberOfRatingOfListingSeller: Returns the number of ratings of the seller of listing with listing id [listingId]

### faceBlock
The faceBlock contract ties the other three contracts together and allows for interfacing with the entirety of FaceBlock Marketplace.

- createAccount: Allows a user to create an account with [_username] and [_password]
- login: Allows a user to login to their account, if they enter the right login credentials
- logout: Logs a user out
- createItem: Creates a new item owned by the msg sender with [name]
- getLast25OpenListings: Accesses the Listings function of the same name
- getItemOwner: Accesses the Item function of the same name
- createListing: Creates a listing with set arguments
- bidOnListing: Allows the user to bid on an auction by paying this function
- endLisitingAsSeller: Calls Listings' sellerEndBidding function
- endListingAsWinningBidder: Calls Listings' highestBidderEndBiddingPostBiddingPeriod function
- rateSellerAsWinnerOfListing: Calls Listings' rateSellerOfListingYouWon function
- getMinBidPriceForLising: Calls the Listings function of the same name
- getSecondsBeforeBiddingEndsForListing: Calls the Listings function of the same name
- getRatingOfListingSeller: Calls the Listings function of the same name
- getNumberOfRatingOfListingSeller: Calls the Listings function of the same name


