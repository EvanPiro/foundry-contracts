// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract DeployAndMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 feeCollectorAddress = vm.envUint("FEE_COLLECTOR_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        NFTPrinter nftPrinterImpl = new NFTPrinter();
        new TransparentUpgradeableProxy(
            address(nftPrinterImpl),
            address(this),
            abi.encodeWithSignature("initialize(address)", feeCollectorAddress)
        );

        vm.stopBroadcast();
    }
}
