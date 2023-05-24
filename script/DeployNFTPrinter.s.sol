// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployNFTPrinter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        address feeCollectorAddress = vm.envAddress("FEE_COLLECTOR_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        NFTPrinter nftPrinterImpl = new NFTPrinter();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(nftPrinterImpl),
            deployerAddress,
            abi.encodeWithSignature("initialize(address)", feeCollectorAddress)
        );

        vm.stopBroadcast();
    }
}
