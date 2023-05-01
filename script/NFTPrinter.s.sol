// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTPrinter.sol";

contract DeployAndMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddr = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        NFTPrinter nftPrinter = new NFTPrinter();

        string memory uri = "ipfs://bafkreidjvcymdofy3wnq5epkxlyibrng3ik6yllxaaio7ggxvykatnsvti";

        nftPrinter.printNFT(deployerAddr, uri);

        vm.stopBroadcast();
    }
}