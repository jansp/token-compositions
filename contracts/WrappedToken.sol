// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../contracts/ChainRelay.sol";


/** @title Wrapped Token Contract */
contract WrappedToken is ERC721 {
    
    address internal _owner;
    ChainRelay internal _relayContract;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Map tokenId to (remaining) balance of token/batch
    mapping(uint256 => uint256) private _tokenBalance;
    
    modifier isOwner() {
        require(msg.sender == _owner, "Access denied");
        _;
    }

    constructor(string memory componentName, string memory componentShort, address chainRelayAdr) ERC721(componentName, componentShort) {
        _owner = msg.sender;
        _relayContract = ChainRelay(chainRelayAdr);
    }
    

    function mintWrappedToken(uint256 blockNo, bytes memory merkleProof) public isOwner returns (uint256) {

        require(_relayContract.isEventInBlock(blockNo, merkleProof), "Event not in block");
        
        // create new token/batch
        _tokenIds.increment();
    
        uint256 newTokenId = _tokenIds.current();
        _mint(_owner, newTokenId);
        //_tokenBalance[newTokenId] = batchSize;
    
        return newTokenId;
    }   
}
