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
        
        gluedWood = new Component("Glued Wood", "GLW");
        gluedWood.addIngredient(address(glue), 2);
        gluedWood.addIngredient(address(wood), 3);
    }
    
    function mintBasicComponent () public {
        glue.mintBatch(2);
        wood.mintBatch(3);
    }
    
    function transferIngredientsToSawmill () public {
        glue.transferTokens(address(gluedWood), 2);
        wood.transferTokens(address(gluedWood), 3);
    }
    
    function mintComponentWithIngredients() public {
        gluedWood.mintComponent("FirstGluedWood");
    }
    
}

