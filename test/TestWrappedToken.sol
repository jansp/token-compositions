// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Component.sol";
import "../contracts/WrappingContract.sol";

contract TestWrappedToken {
    Component glue;
    Component wood;
    Component gluedWood;

    WrappingContract wrappingContract;
    
    function beforeAll() public {
        glue = new Component("Glue", "GLU", new Ingredient[](0));
        wrappingContract = new WrappingContract();
    }

    function mintBasicComponent () public {
        glue.mintBatch(4, new Batch[](0));
        Assert.equal(glue.getTokenBalance(1), 4, "Unexpected token balance!");
    }
    

    function testTransferToWrappingContractAndLock() public {
        beforeAll();
        mintBasicComponent();

        uint256 tokenId = 1;
        Batch memory batch;
        batch.tId = tokenId;
        batch.adr = address(glue);
        

        glue.approve(address(wrappingContract), tokenId);
        wrappingContract.lock(msg.sender, batch.adr, batch.tId);

        bytes32 token = keccak256(abi.encodePacked(address(glue), tokenId));

        Assert.equal(wrappingContract.getLockedTokenAddress(token), msg.sender, "Token not locked to owner address!");
    }

}

