// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";

contract CollectFees is Script {
    // Goerli Address
    address nftPrinterAddress = 0xa47d17727fDe3826d92A77BE2f83F6fb1d7254e8;

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
