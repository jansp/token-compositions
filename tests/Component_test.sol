// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "../contracts/Component.sol";

contract ComponentTest {
   
    Component glue;
    Component wood;
    Component gluedWood;
    
    function beforeAll () public {
        glue = new Component("Glue", "GLU", new Ingredient[](0));
        wood = new Component("Wooden log", "LOG", new Ingredient[](0));
        
        Ingredient[] memory ingr = new Ingredient[](2);
        ingr[0] = Ingredient(address(glue), 2);
        ingr[1] = Ingredient(address(wood), 3);

        gluedWood = new Component("Glued Wood", "GLW", ingr);
    }
    
    function mintBasicComponent () public {
        glue.mintBatch(4, new Batch[](0));
        wood.mintBatch(6, new Batch[](0));
    }
    
    function approveIngredientsForSawmill () public {
        uint256 tokenId = 1;
        glue.approve(address(gluedWood), tokenId);
        wood.approve(address(gluedWood), tokenId);
    }
    
    function mintComponentWithIngredients() public {
        Batch[] memory batchesToBurn = new Batch[](2);
        
        // define address and batchId to burn
        batchesToBurn[0] = Batch(address(glue), 1);
        batchesToBurn[1] = Batch(address(wood), 1);
        
        gluedWood.mintBatch(1, batchesToBurn);
    }
    
}

