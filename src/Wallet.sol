// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Wallet {
    struct WalletStruct {
        address owner;
        uint256 balance;
    }


    
    WalletStruct[] private wallets;

    mapping(address => uint256) private addr2wallet;

    event WalletCreated(address indexed owner);
    event BalanceAdded(address indexed owner, uint256 amount);
    event BalanceChecked(address indexed owner, uint256 balance);

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
        require(addr2wallet[owner] == 0, "Wallet already exists");

        WalletStruct memory wallet = WalletStruct({
            owner: owner,
            balance: 0
        });

        wallets.push(wallet);
        addr2wallet[msg.sender] = wallets.length - 1;

        emit WalletCreated(owner);
        return true;
    }

    // Function to add balance to the wallet
    function addBalance(address owner, uint256 amount) public onlyOwner(owner) returns (bool) {
        wallets[addr2wallet[owner]].balance += amount;
        emit BalanceAdded(owner, amount);
        return true;
    }

    // Function to check the balance of the wallet
    function checkBalance(address owner) public view onlyOwner(owner) returns (uint256) {
        uint256 balance =  wallets[addr2wallet[owner]].balance;

        return balance;
    }

}

