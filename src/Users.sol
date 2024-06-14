// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Users {

    struct User {

        // User info
        string username;
        bytes32 passwordHash;

        // Ratings 
        uint256 totalRating; // 1 rating point will be represented as 100 to support decimal rating return
        uint256 numberOfRatings; // user rating will be totalRating / (numberOfRatings * 100)
    }

    // used to check if users are registered
    mapping(address => bool) public registeredUsers;


    // Mapping to store users by their address
    mapping(address => User) private users;

    // Event to log user registration
    event UserRegistered(address userAddress, string username);

    // Function to register a new user
    function registerUser(string memory _username, string memory _password, address caller) public {
        require(registeredUsers[caller] == false, "User already registered");

        // Hash the password before storing it
        bytes32 _passwordHash = keccak256(abi.encodePacked(_password));

        // Store user information
        User memory user = User({
            username: _username,
            passwordHash: _passwordHash,
            totalRating: 0,
            numberOfRatings: 0
        });

        users[caller] = user;

        registeredUsers[caller] = true;

    }


    // Function to authenticate a user
    function authenticateUser(string memory _username, string memory _password, address caller) public view returns (bool) {
       require(registeredUsers[caller] == true, "User not registered");
       User memory user = users[caller];

        // Check if the username matches and the password hash matches
        if (keccak256(abi.encodePacked(user.username)) == keccak256(abi.encodePacked(_username)) &&
            user.passwordHash == keccak256(abi.encodePacked(_password))) {
            return true;
        }
        return false;
    }


    function getUsername(address addressOfUser) public view returns (string memory) {
        require(registeredUsers[addressOfUser] == true, "User not registered");
        return users[addressOfUser].username;
    }
    
    function submitRating(address userAddress, uint rating, address caller) public {
        require(rating >= 0 && rating <= 5, "Rating must be between 0 and 5 stars");
        require(registeredUsers[caller] == true, "Function caller not registered");
        require(caller != userAddress, "Users cannot rate themselves");

        users[userAddress].totalRating += rating * 100;
        users[userAddress].numberOfRatings++;
    }

    function getAverageRating(address userAddress) public view returns (uint256) {
        require(registeredUsers[userAddress] == true, "Function caller not registered");
        User memory user = users[userAddress];
        if (user.numberOfRatings == 0) {
            return 0; // No ratings yet, return 0
        }
        return user.totalRating / user.numberOfRatings;
    }

    function getNumberOfRatings(address userAddress) public view returns (uint256) {
        require(registeredUsers[userAddress] == true, "Function caller not registered");
        return users[userAddress].numberOfRatings;
    }
    
}
