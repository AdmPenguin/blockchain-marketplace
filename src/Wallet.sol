// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Wallet {
    struct WalletStruct {
        address owner;
        uint256 balance;
        mapping(uint256 => bool) itemsOwned; // mapping of item IDs to ownership status
    }

    mapping(address => WalletStruct) private wallets;

    event WalletCreated(address indexed owner);
    event BalanceAdded(address indexed owner, uint256 amount);
    event ItemAdded(address indexed owner, uint256 itemId);
    event BalanceChecked(address indexed owner, uint256 balance);
    event ItemOwnershipChecked(address indexed owner, uint256 itemId, bool isOwner);

    modifier onlyOwner(address owner) {
        require(msg.sender == owner, "Only the wallet owner can perform this action");
        _;
    }

    constructor() {
        // Optionally, create a default wallet for the deployer
        createWallet(msg.sender);
    }

    // Function to create a wallet
    function createWallet(address owner) public returns (bool) {
        require(wallets[owner].owner == address(0), "Wallet already exists");

        wallets[owner] = WalletStruct({
            owner: owner,
            balance: 0
        });

        emit WalletCreated(owner);
        return true;
    }

    // Function to add balance to the wallet
    function addBalance(address owner, uint256 amount) public onlyOwner(owner) returns (bool) {
        wallets[owner].balance += amount;

        emit BalanceAdded(owner, amount);
        return true;
    }

    // Function to check the balance of the wallet
    function checkBalance(address owner) public view onlyOwner(owner) returns (uint256) {
        uint256 balance = wallets[owner].balance;

        emit BalanceChecked(owner, balance);
        return balance;
    }

    // Function to add an item to the wallet
    function addItem(address owner, uint256 itemId) public onlyOwner(owner) returns (bool) {
        wallets[owner].itemsOwned[itemId] = true;

        emit ItemAdded(owner, itemId);
        return true;
    }

    // Function to check if an item is owned by the wallet
    function isItemOwned(address owner, uint256 itemId) public view onlyOwner(owner) returns (bool) {
        bool isOwner = wallets[owner].itemsOwned[itemId];

        emit ItemOwnershipChecked(owner, itemId, isOwner);
        return isOwner;
    }
}

