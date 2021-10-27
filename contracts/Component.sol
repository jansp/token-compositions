// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Component is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    bool internal hasIngredients = false;
    address[] internal ingredients;
    uint256[] internal ingredientCount;
    
    address owner;
    uint256 curToken = 0;
    
    
    constructor(string memory componentName, string memory componentShort) ERC721(componentName, componentShort) {
        owner = msg.sender;
    }
    
    // Call when initializing component that has ingredients
    function setIngredients(address[] memory _ingredients, uint256[] memory _ingredientCount) public {
        ingredients = _ingredients;
        ingredientCount = _ingredientCount;
        hasIngredients = true;
    }

    function mintComponent(string memory tokenURI) internal returns (uint256) {
        if(!hasIngredients) {
            _tokenIds.increment();
    
            uint256 newItemId = _tokenIds.current();
            _mint(owner, newItemId);
            _setTokenURI(newItemId, tokenURI);
    
            return newItemId;
        }
    }
    
    uint256 batchNo = 0;
    mapping (uint256 => uint256) public batch;
    mapping (uint256 => uint256) internal batchSize;
    
    function mintBatch(uint256 amount) public returns (uint256) {
        batchNo++;
        uint256 cID;
        
        for(uint256 i=0; i < amount; i++) {
            cID = mintComponent("TEST");
            batch[cID] = batchNo;
        }
        
        batchSize[batchNo] = amount;
        
        return batchNo;
    }
    
    mapping (uint256 => address) internal batchOwner;
    

    /*
    function transferBatch(address _to, uint256 _batchNo) public {
        // TODO loop through batch
        for(uint256 i=0; i < _batchNo; i++) {
            
        }
        
        safeTransferFrom(owner, _to, _tokenIds.current());
        batchOwner[_batchNo] = _to;
    }
    
    function burnBatch(uint256 _batchNo) public {
        
    }
    */
    
    function transferToken(address to) public {
        safeTransferFrom(owner, to, curToken);
        curToken++;
    }
    
    function transferTokens(address to, int256 amount) public {
        for(int i=0; i < amount; i++) {
            transferToken(to);
        }
    }
    
    // from ERC721Burnable
    function burn(uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    
}
