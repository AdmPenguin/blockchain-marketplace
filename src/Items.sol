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

    function createItem(string memory _name, address caller) public returns(uint){
        require(userManager.registeredUsers(caller), "User not registered");
        Item memory newItem = Item(nextItemId, caller, _name);
        items.push(newItem);
        emit ItemCreated(nextItemId, caller, _name);
        nextItemId++;

        return newItem.id;
    }

    function transferItem(uint _itemId, address _to, address caller) public returns(bool){
        require(userManager.registeredUsers(_to), "Recipient not registered");
        require(items[_itemId].owner == caller, "Not the item owner");
        items[_itemId].owner = _to;
        emit ItemTransferred(_itemId, caller, _to);
        return true;
    }

    function getItemOwner(uint _itemId) public view returns(address){
        require(_itemId < nextItemId, "Item does not exists");
        return items[_itemId].owner;
    }

}