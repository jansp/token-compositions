// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../contracts/Component.sol";


struct Token {
    address tContract;
    uint256 tId;
}

contract WrappingContract is IERC721Receiver {

    address internal _owner;

    mapping (address => Token) lockedTokens;
    event locked(address to, address tokenContract, uint256 tokenId);

    modifier isOwner() {
        require(msg.sender == _owner, "Access denied");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function lock(address to, address tokenContract, uint256 tokenId) public {
        ERC721 c = ERC721(tokenContract);

        // require msg.sender owns token
        require(msg.sender == c.ownerOf(tokenId));

        // require preceding approval for wrapping contract
        require(c.getApproved(tokenId) == address(this));

        // "take ownership" (send token to self)
        c.safeTransferFrom(msg.sender, address(this), tokenId);

        // lock token to address
        lockToken(to, tokenContract, tokenId);

    }

    function lockToken(address to, address tokenContract, uint256 tokenId) internal {
        Token memory t;
        t.tContract = tokenContract;
        t.tId = tokenId;

        lockedTokens[to] = t;
        emit locked(to, tokenContract, tokenId);
    }

    function onERC721Received(address /*operator*/, address /*from*/, uint256 /*tokenId*/, bytes memory) public virtual override returns (bytes4) {
        /*
        Batch memory b;
        b.adr = from;
        b.tId = tokenId;

        lockToken(operator, b);
        */

        return this.onERC721Received.selector;
    }
}
