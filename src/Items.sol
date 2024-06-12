// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Users} from "../src/Users.sol";


contract Items {

    Users public userManager;

    struct Item {
        uint id;
        address owner;
        string name;
    }

    Item[] public items;

    uint public nextItemId = 0;

    

    event ItemCreated(uint itemId, address owner, string name);
    event ItemTransferred(uint itemId, address from, address to);

    constructor(Users _userManager) {
        userManager = _userManager;
    }

    function createItem(string memory _name) public returns(uint){
        require(userManager.registeredUsers(msg.sender), "User not registered");
        Item memory newItem = Item(nextItemId, msg.sender, _name);
        items.push(newItem);
        emit ItemCreated(nextItemId, msg.sender, _name);
        nextItemId++;

        return newItem.id;
    }

    function transferItem(uint _itemId, address _to) public returns(bool){
        require(userManager.registeredUsers(_to), "Recipient not registered");
        require(items[_itemId].owner == msg.sender, "Not the item owner");
        items[_itemId].owner = _to;
        emit ItemTransferred(_itemId, msg.sender, _to);
        return true;
    }

    function getItemOwner(uint _itemId) public view returns(address){
        require(_itemId < nextItemId, "Item does not exists");
        return items[_itemId].owner;
    }

}