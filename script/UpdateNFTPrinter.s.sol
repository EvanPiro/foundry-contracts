// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinterV2.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/NFTPrinter.sol";
import "lib/openzeppelin-contracts/contracts/utils/Address.sol";

contract UpdateNFTPrinter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address payable proxyAddress = payable(vm.envAddress("SEPOLIA_NFT_PRINTER_PROXY"));

        vm.startBroadcast(deployerPrivateKey);

        console.log(address(this));

        NFTPrinterV2 nftPrinterV2 = new NFTPrinterV2();
        TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(proxyAddress);

        proxy.upgradeTo(address(nftPrinterV2));

        vm.stopBroadcast();
    }
}
