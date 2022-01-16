// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Component.sol";
import "../contracts/ComponentFactory.sol";
import "../contracts/WrappingContract.sol";

contract TestComponent {
    Component glue;
    Component wood;
    Component gluedWood;
    
    function testBeforeAll() public {
        glue = new Component("Glue", "GLU", new Ingredient[](0));
        wood = new Component("Wooden log", "LOG", new Ingredient[](0));        
    }
    
    function testTokenComposition() public {
        Ingredient[] memory ingr = new Ingredient[](2);
        ingr[0] = Ingredient(address(glue), 2);
        ingr[1] = Ingredient(address(wood), 3);

        gluedWood = new Component("Glued Wood", "GLW", ingr);
    }

    function testMintBasicComponent () public {
        glue.mintBatch(4, new Batch[](0));
        wood.mintBatch(6, new Batch[](0));

        Assert.equal(glue.getTokenBalance(1), 4, "Unexpected token balance!");
        Assert.equal(wood.getTokenBalance(1), 6, "Unexpected token balance!");
    }
    
    function testApproveIngredientsForComposedComponent () public {
        uint256 tokenId = 1;
        glue.approve(address(gluedWood), tokenId);
        wood.approve(address(gluedWood), tokenId);

        Assert.equal(glue.getApproved(1), address(gluedWood), "Glue not approved to gluedWood contract!");
        Assert.equal(wood.getApproved(1), address(gluedWood), "Wood not approved to gluedWood contract!");
    }
    
    function testMintComponentWithIngredients() public {
        Batch[] memory batchesToBurn = new Batch[](2);
        
        // define address and batchId to burn
        batchesToBurn[0] = Batch(address(glue), 1);
        batchesToBurn[1] = Batch(address(wood), 1);
        
        gluedWood.mintBatch(2, batchesToBurn);

        Assert.equal(gluedWood.getTokenBalance(1), 2, "Wrong batchsize of gluedWood!");
    }
}

