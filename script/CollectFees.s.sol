// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";

contract CollectFees is Script {
    // Goerli Address
    address nftPrinterAddress = 0x394a4aA08CF1D102db582497db13b9e85C3A4762;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        NFTPrinter nftPrinter = NFTPrinter(nftPrinterAddress);
        if (nftPrinterAddress.balance >= 10_000_000 gwei) {
            nftPrinter.collect();
        }
        vm.stopBroadcast();
    }
}
