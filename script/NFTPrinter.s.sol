// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";

contract DeployAndMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        NFTPrinter nftPrinter = new NFTPrinter();

//        address deployerAddr = vm.addr(deployerPrivateKey);
//        string memory uri = "ipfs://bafkreicgynawxgcws6frx6jyp5wpc7klfrfwjjdjkadnhdu5ww4mruup6m";
//
//        nftPrinter.printNFT(deployerAddr, uri);

        vm.stopBroadcast();
    }
}