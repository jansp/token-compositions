// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../contracts/Component.sol";

contract ComponentTest {
   
    bytes32[] proposalNames;
   
    
    Component glue;
    Component wood;
    Component gluedWood;
    
    function beforeAll () public {
        glue = new Component("Glue", "GLU");
        wood = new Component("Wooden log", "LOG");
    }
    
    function mintBasicComponent () public {
        glue.mintBatch(30);    
    }
}

