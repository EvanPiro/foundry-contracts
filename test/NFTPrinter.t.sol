pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/NFTPrinter.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract NFTPrinterTest is Test {
    NFTPrinter nftPrinter;

    function setUp() public {
        nftPrinter = new NFTPrinter();

    }

    function testIsTransferredNFT() public {
        uint cid = 9;
        nftPrinter.printNFT(cid);
        uint nftBalance = nftPrinter.balanceOf(address(this));
        assertEq(nftBalance, 1);
    }

    function testPrinterBalance() public {
        uint cid = 9;
        nftPrinter.printNFT(cid);
        nftPrinter.transferFrom(address(this), vm.addr(1), cid);
        uint receiverBalance = nftPrinter.balanceOf(vm.addr(1));
        uint senderBalance = nftPrinter.balanceOf(address(this));
        assertEq(senderBalance, 0);
        assertEq(receiverBalance, 1);
    }

//    function testIsNotVerifiedData() public {
//        bytes memory message = "this is a test";
//
//        bytes32 hash = keccak256(message);
//        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, hash);
//
//        assertFalse(signedData.isVerifiedData(message, v, r, s));
//    }
}
