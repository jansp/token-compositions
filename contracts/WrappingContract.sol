// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../contracts/Component.sol";


contract WrappingContract is IERC721Receiver {
    address internal _owner;

    mapping (bytes32 => address) lockedTokens;
    event locked(address to, address tokenContract, uint256 tokenId);

    modifier isOwner() {
        require(msg.sender == _owner, "Access denied");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    
    /** @dev locks token to address
     *  @param to receiver,
     *  @param tokenContract ERC721 contract address
     *  @param tokenId Batch ID
     */
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

    /** @dev Saves locked token to mapping and emits lock event
     *  @param to receiver,
     *  @param tokenContract ERC721 contract address
     *  @param tokenId Batch ID
     */
    function lockToken(address to, address tokenContract, uint256 tokenId) internal {
        bytes32 token = keccak256(abi.encodePacked(tokenContract, tokenId));

        lockedTokens[token] = to;
        emit locked(to, tokenContract, tokenId);
    }

    function getLockedTokenAddress(bytes32 token) public view returns (address) {
        return lockedTokens[token];
    }

    function onERC721Received(address /*operator*/, address /*from*/, uint256 /*tokenId*/, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
