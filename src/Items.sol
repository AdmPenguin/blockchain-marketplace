// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Users} from "../src/Users.sol";


contract ItemManager {
    struct Item {
        uint id;
        address owner;
        string name;
        uint price;
    }

    Item[] public items;

    uint public nextItemId;

    Users public userManager;

    event ItemCreated(uint itemId, address owner, string name, uint price);
    event ItemTransferred(uint itemId, address from, address to);

    constructor(address _userManager) {
        userManager = Users(_userManager);
    }

    function createItem(string memory _name, uint _price) public {
        require(userManager.registeredUsers(msg.sender), "User not registered");
        items.push(Item(nextItemId, msg.sender, _name, _price));
        emit ItemCreated(nextItemId, msg.sender, _name, _price);
        nextItemId++;
    }

    function transferItem(uint _itemId, address _to) public {
        require(userManager.registeredUsers(_to), "Recipient not registered");
        require(items[_itemId].owner == msg.sender, "Not the item owner");
        items[_itemId].owner = _to;
        emit ItemTransferred(_itemId, msg.sender, _to);
    }

    function getItemOwner(uint _itemId) public view returns(address){
        require(_itemId < nextItemId, "Item does not exists");

        return items[_itemId].owner;
    }

}