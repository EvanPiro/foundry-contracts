# Upgradeable Contracts

## Proxy Slot Randomization
A proxy contract chooses a randomized slot to store the implementation address so that the slot doesn't collide with the slots specified by the implementation contract.

[ERC-1967](https://eips.ethereum.org/EIPS/eip-1967)

[OpenZeppelin Docs](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies)

## Transparent Proxies
Proxy is ownable. When owner calls proxy, calls are not delegated. This avoids method collision.

## Deploying Proxies
In order to deploy a proxy, you must do the following
1. Deploy the contract you wish to contain your logic.
2. Deploy a proxy with the address of the logic contract, the owner that will only be able to call proxy methods as referred to above, and the function call to logic contract for initialization vai `abi.encodeWithSignature`.

```solidity
nftPrinterImpl = new NFTPrinter();
proxy = new TransparentUpgradeableProxy(
    address(nftPrinterImpl),
    deployer,
    abi.encodeWithSignature("initialize(address)", address(this))
);

nftPrinter = NFTPrinter(address(proxy));
```