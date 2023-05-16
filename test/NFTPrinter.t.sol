pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/NFTPrinter.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract NFTPrinterTest is Test {
    NFTPrinter nftPrinter;
    uint256 fee = 10_000_000 gwei;
    address owner = address(1);

    function setUp() public {
        vm.prank(owner);
        nftPrinter = new NFTPrinter();
    }

    function test_NFTIsTransferred() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        uint256 id = nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);
        uint256 nftBalance = nftPrinter.balanceOf(senderAddress);
        address ownerAddress = nftPrinter.ownerOf(id);
        assertEq(nftBalance, 1);
        assertEq(ownerAddress, senderAddress);
    }

    function test_TokenBalancesAreCorrect() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        address receiverAddress = vm.addr(1);
        uint256 id = nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);
        nftPrinter.safeTransferFrom(senderAddress, receiverAddress, id);
        uint256 receiverBalance = nftPrinter.balanceOf(receiverAddress);
        uint256 senderBalance = nftPrinter.balanceOf(senderAddress);
        address ownerAddress = nftPrinter.ownerOf(id);
        assertEq(senderBalance, 0);
        assertEq(receiverBalance, 1);
        assertEq(ownerAddress, receiverAddress);
    }

    function test_FeesIsStored() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);
        uint256 contractBalance = address(nftPrinter).balance;
        assertEq(contractBalance, fee);
    }

    function test_FeeIsCollectable() public {
        vm.deal(address(nftPrinter), fee);
        vm.prank(owner);
        nftPrinter.collect();
        assertEq(address(nftPrinter).balance, 0);
        assertEq(owner.balance, fee);
    }

    function test_NonTokenOwnerCannotListNFT() public {
        address culprit = address(2);
        vm.deal(culprit, fee);

        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);

        vm.prank(culprit);
        vm.expectRevert("Must be token owner to set listing");
        nftPrinter.setListing(tokenId, fee);
    }

    function test_TokenOwnerCanListNFT() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);
        nftPrinter.setListing(tokenId, fee);
        assertEq(nftPrinter.getListing(tokenId), fee);
    }

    function test_NonOwnerCannotSetMintFee() public {
        address culprit = address(2);
        vm.deal(address(culprit), fee);
        vm.prank(culprit);
        vm.expectRevert();
        nftPrinter.setMintFee(0 gwei);
    }

    function test_OwnerCanSetMintFee() public {
        vm.deal(address(owner), fee);
        vm.prank(owner);
        nftPrinter.setMintFee(0 gwei);
        assertEq(nftPrinter.mintFee(), 0 gwei);
    }

    function test_BuyerWillReceiveListingAndSellerPaid() public {
        address buyer = address(2);
        vm.deal(buyer, fee * 2);
        address seller = address(3);
        vm.deal(seller, fee);
        string memory tokenURI = "https://example.com";
        uint256 tokenId = nftPrinter.printNFT{value: fee}(seller, tokenURI);
        vm.prank(seller);
        nftPrinter.setListing(tokenId, fee);

        assertEq(nftPrinter.getApproved(tokenId), address(nftPrinter));

        vm.prank(buyer);
        nftPrinter.buyListing{value: fee}(tokenId);

        assertEq(nftPrinter.ownerOf(tokenId), buyer);
    }
}
