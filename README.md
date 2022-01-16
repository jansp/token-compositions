# token_compositions

## Compile contracts:
`truffle compile`

## Migrate:
`ganache-cli -p 7545 -i 5777 -s "42"`

`truffle migrate`

## Run tests (while ganache instance is running):
`truffle test`


# Project strucure

## Contracts:

### Component.sol:
ERC721 token contract on chain A

### WrappingContract.sol
Token wrapping contract on chain A

### ChainRelay.sol
Relay contract on chain B

### WrappedToken.sol
Wrapped token contract on chain B

