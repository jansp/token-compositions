// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


struct Batch {
    address adr;
    uint256 tId;
}

struct Ingredient {
    address adr;
    uint256 amount;
}

/** @title Token Compositions Contract */
contract Component is IERC721Receiver, ERC721Enumerable {
    
    address internal _owner;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Map tokenId to (remaining) balance of token/batch
    mapping(uint256 => uint256) private _tokenBalance;
    
    // Manage token ingredients
    Ingredient[] internal _ingredients;
    bool internal _hasIngredients = false;

    
    modifier isOwner() {
        require(msg.sender == _owner, "Access denied");
        _;
    }
    
    /** @dev Component constructor
     *  @param componentName Name of component
     *  @param componentShort Abbreviation of component name
     *  @param ingr Array of Ingredients (Pass empty array for basic component)
     */
    constructor(string memory componentName, string memory componentShort, Ingredient[] memory ingr) ERC721(componentName, componentShort) {
        _owner = msg.sender;
        
        if (ingr.length > 0) {
            _hasIngredients = true;
            for(uint i=0; i < ingr.length; i++) {
                _ingredients.push(ingr[i]);
            }
        }
    }
    

    /** @dev Mint new batch of components
     *  @param batchSize Size of new batch
     *  @param batchesToBurn Array with addresses & batch IDs of ingredients to burn for batch creation
     *  @return newTokenId TokenID of newly minted batch
     */
    function mintBatch(uint256 batchSize, Batch[] memory batchesToBurn) public isOwner returns (uint256) {
        require(batchSize >= 1);
        
        if (_hasIngredients) {
            // TODO add batch merging
            
            // check for ingredients
            for(uint256 i=0; i < _ingredients.length; i++) {
                require(_ingredients[i].adr == batchesToBurn[i].adr, "Batches provided in wrong order");
                uint256 amountNeededPerItem = _ingredients[i].amount;
                uint256 tokenToBurn = batchesToBurn[i].tId;
                Component c = Component(_ingredients[i].adr);
                require(c.getTokenBalance(tokenToBurn) >= amountNeededPerItem * batchSize);
            }
            
            
            // burn ingredients
            for(uint256 i=0; i < _ingredients.length; i++) {
                Component c = Component(_ingredients[i].adr);
                c.burn(batchesToBurn[i].tId, batchSize * _ingredients[i].amount);
            }
        }
        
        
        // create new token/batch
        _tokenIds.increment();
    
        uint256 newTokenId = _tokenIds.current();
        _mint(_owner, newTokenId);
        _tokenBalance[newTokenId] = batchSize;
    
        return newTokenId;
    }
    
    
    /** @dev Returns remaining balance of a batch
     *  @param tokenId Batch ID
     *  @return _tokenBalance[tokenId] Remaining balance of batch
     */
    function getTokenBalance(uint256 tokenId) public view returns (uint256) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        
        return _tokenBalance[tokenId];
    }
    
    /** @dev Reduce batch by amount
     *  @param tokenId Batch ID to use
     *  @param amount Amount to burn
     */
    function burn(uint256 tokenId, uint256 amount) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        require(_tokenBalance[tokenId] >= amount, "Balance too low");
        
        _tokenBalance[tokenId] -= amount;
        
        if(_tokenBalance[tokenId] == 0) {
            _burn(tokenId);
        }
    }
    
    
    function onERC721Received(address, address from, uint256 tokenId, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}
