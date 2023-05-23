# Upgradeable Contracts

## Proxy Slot Randomization
A proxy contract chooses a randomized slot to store the implementation address so that the slot doesn't collide with the slots specified by the implementation contract.

[ERC-1967](https://eips.ethereum.org/EIPS/eip-1967)

[OpenZeppelin Docs](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies)

## Transparent Proxies
Proxy is ownable. When owner calls proxy, calls are not delegated. This avoids method collision.
