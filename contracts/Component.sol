pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Component is ERC721URIStorage, IERC721Receiver {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    bool internal hasIngredients = false;
    address[] internal ingredients;
    uint256[] internal ingredientCount;
    
    address owner;
    uint256 curToken = 0;
    
    mapping (address => uint256[]) internal ownedTokens;
    
    
    constructor(string memory componentName, string memory componentShort) ERC721(componentName, componentShort) {
        owner = msg.sender;
    }
    

    function addIngredient(address _ingredientAdr, uint256 _amount) public {
        require(msg.sender == owner);
        
        hasIngredients = true;
        ingredients.push(_ingredientAdr);
        ingredientCount.push(_amount);
    }

    function mintComponent(string memory tokenURI) public payable returns (uint256) {
        require(msg.sender == owner);
        
        if (hasIngredients) {
            for(uint256 i=0; i < ingredients.length; i++) {
                Component(ingredients[i]).burn(ownedTokens[ingredients[i]][0]);    
            }
            // TODO revert if burning all tokens doesn't succeed
            
        }
        
        _tokenIds.increment();
    
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI);
    
        return newItemId;
    }
    
    uint256 batchNo = 0;
    mapping (uint256 => uint256) public batch;
    mapping (uint256 => uint256) internal batchSize;
    
    function mintBatch(uint256 amount) public returns (uint256) {
        require(msg.sender == owner);
        
        batchNo++;
        uint256 cID;
        
        for(uint256 i=0; i < amount; i++) {
            cID = mintComponent("TEST");
            batch[cID] = batchNo;
        }
        
        batchSize[batchNo] = amount;
        
        //return _tokenIds.current();
        return batchNo;
    }
    
    mapping (uint256 => address) public batchOwner;
    

    function transferBatch(address _to, uint256 _batchNo) public {
        for(uint256 i=0; i < _batchNo; i++) {
            
        }
        
        //safeTransferFrom(owner, _to, _tokenIds.current());
        batchOwner[_batchNo] = _to;
    }

    
    function transferToken(address to) internal returns (uint256) {
        require(msg.sender == owner);
        
        curToken++;
        safeTransferFrom(owner, to, curToken);
        //ownedTokens[to].push(curToken);
        
        return curToken;
    }
    
    function transferTokens(address to, uint256 amount) public {
        require(msg.sender == owner);
        
        for(uint256 i=0; i < amount; i++) {
            transferToken(to);
        }
    }
    
    // from ERC721Burnable
    function burn(uint256 tokenId) public payable {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    
    
    function onERC721Received(address from, address, uint256 tID, bytes memory) public virtual override returns (bytes4) {
        ownedTokens[from].push(tID);
        return this.onERC721Received.selector;
    }
    
}
