// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../contracts/Component.sol";
import "../contracts/WrappingContract.sol";

contract ComponentTest {
   
    Component glue;
    Component wood;
    Component gluedWood;

    WrappingContract wrappingContract;
    
    function beforeAll () public {
        glue = new Component("Glue", "GLU", new Ingredient[](0));
        wood = new Component("Wooden log", "LOG", new Ingredient[](0));
        
        Ingredient[] memory ingr = new Ingredient[](2);
        ingr[0] = Ingredient(address(glue), 2);
        ingr[1] = Ingredient(address(wood), 3);

        gluedWood = new Component("Glued Wood", "GLW", ingr);

        wrappingContract = new WrappingContract();
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

    function transferToWrappingContractAndLock(address to) public {
        uint256 tokenId = 1;
        Batch memory batch;
        batch.tId = tokenId;
        batch.adr = address(glue);
        

        glue.approve(address(wrappingContract), tokenId);
        wrappingContract.lock(to, batch.adr, batch.tId);
    }
    
}

