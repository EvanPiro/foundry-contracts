# Chainlink

Chainlink exposes data feeds through the `AggregatorV3Interface` providing the following data to calling contracts:
```solidity
(uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
```

Additionally, the contract also returns the decimals places of the data and a description.

[Reference](https://docs.chain.link/data-feeds/api-reference).