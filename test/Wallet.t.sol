// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet private wallet;

    address private owner;
    address private other;

    function setUp() public {
        wallet = new Wallet();
        owner = address(0x123);
        other = address(0x456);

        // Create wallets for owner and other
        wallet.createWallet(owner);
        wallet.createWallet(other);
    }

    function testCreateWallet() public {
        address newOwner = address(0x789);
        bool result = wallet.createWallet(newOwner);
        assertTrue(result, "Failed to create wallet");

        // Check that wallet was created successfully
        uint256 balance = wallet.checkBalance(newOwner);
        assertEq(balance, 0, "Initial balance should be zero");
    }

    function testAddBalance() public {
        uint256 amount = 1000;
        bool result = wallet.addBalance(owner, amount);
        assertTrue(result, "Failed to add balance");

        // Check that balance was added correctly
        uint256 balance = wallet.checkBalance(owner);
        assertEq(balance, amount, "Balance did not match expected value");
    }

    function testCheckBalance() public {
        uint256 initialAmount = 500;
        wallet.addBalance(owner, initialAmount);

        uint256 balance = wallet.checkBalance(owner);
        assertEq(balance, initialAmount, "Balance did not match expected value");
    }

    function testAddItem() public {
        uint256 itemId = 1;
        bool result = wallet.addItem(owner, itemId);
        assertTrue(result, "Failed to add item");

        // Check that item was added correctly
        bool isOwned = wallet.isItemOwned(owner, itemId);
        assertTrue(isOwned, "Item should be owned");
    }

    function testIsItemOwned() public {
        uint256 itemId = 1;
        wallet.addItem(owner, itemId);

        bool isOwned = wallet.isItemOwned(owner, itemId);
        assertTrue(isOwned, "Item should be owned");

        bool isOtherOwned = wallet.isItemOwned(other, itemId);
        assertFalse(isOtherOwned, "Other should not own the item");
    }
}

