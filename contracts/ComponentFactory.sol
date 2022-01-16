// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/Component.sol";


/** @title Token Compositions Contract */
contract ComponentFactory {

    function newComponent(string memory name, string memory short, Ingredient[] memory ingr) public returns (Component) {
        return new Component(name, short, ingr);
    }
}