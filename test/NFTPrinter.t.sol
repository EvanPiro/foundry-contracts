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
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        uint256 id = nftPrinter.printNFT(senderAddress, tokenURI);
        uint256 nftBalance = nftPrinter.balanceOf(senderAddress);
        address ownerAddress = nftPrinter.ownerOf(id);
        assertEq(nftBalance, 1);
        assertEq(ownerAddress, senderAddress);
    }

    function testPrinterBalance() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        address receiverAddress = vm.addr(1);
        uint256 id = nftPrinter.printNFT(senderAddress, tokenURI);
        nftPrinter.safeTransferFrom(senderAddress, receiverAddress, id);
        uint256 receiverBalance = nftPrinter.balanceOf(receiverAddress);
        uint256 senderBalance = nftPrinter.balanceOf(senderAddress);
        address ownerAddress = nftPrinter.ownerOf(id);
        assertEq(senderBalance, 0);
        assertEq(receiverBalance, 1);
        assertEq(ownerAddress, receiverAddress);
    }
}
