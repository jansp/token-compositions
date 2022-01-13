// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainRelay  {
    address internal _wrappingContract;
    address internal _relayer;
    mapping (int256 => bytes) internal _blockHeader;
    int256 internal _latestBlock = -1;

    constructor(address wrappingContract, address relayer) {
        _wrappingContract = wrappingContract;
        _relayer = relayer;
    }

    function isEventInBlock(uint256 blockNo, bytes memory merkleproof) public returns (bool) {
        return true;
    }

    function addBlockHeader(int256 blockNo, bytes memory blockheader) public returns (bool) {
        require(msg.sender == _relayer);
        require(blockNo > _latestBlock);

        _blockHeader[blockNo] = blockheader;
        _latestBlock = blockNo;
    }

}
