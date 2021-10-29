// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Component is IERC721Receiver, ERC721Enumerable {
    
    address owner;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Manage token ingredients
    bool internal hasIngredients = false;
    address[] internal ingredients;
    uint256[] internal ingredientCount;
    uint256 noIngredients = 0;
    
    // Token counter
    uint256 curToken = 0;
    
    // Tracks approved tokens per adr, _approvedTokens[adr][idx] = tokenID
    mapping(address => mapping(uint256 => uint256)) private _approvedTokens;
    
    // Tracks approved tokens per adr, _approvedTokensIdx[adr][tokenID] = idx
    mapping(address => mapping(uint256 => uint256)) private _approvedTokensIdx;
    
    // Track no. of approved tokens per adr
    mapping(address => uint256) private _tokenCount;
    
    
    constructor(string memory componentName, string memory componentShort) ERC721(componentName, componentShort) {
        owner = msg.sender;
    }
    

    function addIngredient(address ingredientAdr, uint256 amount) public {
        require(msg.sender == owner);
        
        hasIngredients = true;
        ingredients.push(ingredientAdr);
        ingredientCount.push(amount);
        noIngredients++;
    }


    function mintComponent() public returns (uint256) {
        require(msg.sender == owner);
        
        if (hasIngredients) {
            // check for ingredients
            for(uint256 i=0; i < noIngredients; i++) {
                require(Component(ingredients[i]).approvedBalance(address(this)) >= ingredientCount[i]);
            }
            
            
            // burn ingredients
            for(uint256 i=0; i < noIngredients; i++) {
                Component c = Component(ingredients[i]);
                for(uint256 j=0; j < ingredientCount[i]; j++) {
                    uint256 tID = c.approvedTokenAtIdx(j);
                    c.burn(tID);
                }
            }
        }
        
        _tokenIds.increment();
    
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        //approve(address(this), newItemId);
    
        return newItemId;
    }
    
    uint256 batchNo = 0;
    mapping (uint256 => uint256) public batch;
    mapping (uint256 => uint256) internal batchSize;
    
    function mintBatch(uint256 amount) public returns (uint256) {
        require(msg.sender == owner);
        
        
        if (hasIngredients) {
            // check for ingredients
            for(uint256 i=0; i < noIngredients; i++) {
                require(Component(ingredients[i]).approvedBalance(address(this)) >= ingredientCount[i] * amount);
            }
        }
        
        batchNo++;
        uint256 cID;
        
        for(uint256 i=0; i < amount; i++) {
            cID = mintComponent();
            // TODO revert if minting one component fails
            batch[cID] = batchNo;
        }
        
        batchSize[batchNo] = amount;

        return batchNo;
    }


    // approve token (make burnable for address "to")
    function transferToken(address to) internal returns (uint256) {
        require(msg.sender == owner);
        
        curToken++;
        //safeTransferFrom(owner, to, curToken);
        approve(to, curToken);
        uint256 curr = _tokenCount[to];
        _approvedTokens[to][curr] = curToken;
        _approvedTokensIdx[to][curToken] = curr;
        _tokenCount[to] += 1;
        return curToken;
    }
    
    function transferTokens(address to, uint256 amount) public {
        require(msg.sender == owner);
        
        for(uint256 i=0; i < amount; i++) {
            transferToken(to);
        }
    }
    
    
    function burn(uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
        uint256 idx = _approvedTokens[msg.sender][tokenId];
        _approvedTokens[msg.sender][idx] = _approvedTokens[msg.sender][_tokenCount[msg.sender] - 1];
        _tokenCount[msg.sender]--;
    }
    
    // Get amount of approved tokens for adr
    function approvedBalance(address adr) public view returns (uint256) {
        return _tokenCount[adr];
    }
    
    // Get tokenID of approved token at index idx
    function approvedTokenAtIdx(uint256 idx) public view returns (uint256) {
        return _approvedTokens[msg.sender][idx];
    }
    
    
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}
