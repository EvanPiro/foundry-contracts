pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/NFTPrinter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract NFTPrinterTest is Test {
    NFTPrinter nftPrinterImpl;
    NFTPrinter nftPrinter;
    uint256 fee = 10_000_000 gwei;
    address user = address(1);
    address deployer = address(4);
    TransparentUpgradeableProxy proxy;

    receive() external payable {}

    function setUp() public {
        nftPrinterImpl = new NFTPrinter();
        proxy = new TransparentUpgradeableProxy(
            address(nftPrinterImpl),
            deployer,
            abi.encodeWithSignature("initialize(address)", address(this))
        );

        nftPrinter = NFTPrinter(address(proxy));
    }

    function test_OwnerIsSet() public {
        assertEq(nftPrinter.owner(), address(this));
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

    function test_FeesIsNotStored() public {
        string memory tokenURI = "https://example.com";
        address senderAddress = address(this);
        nftPrinter.printNFT{value: fee}(senderAddress, tokenURI);
        uint256 contractBalance = address(nftPrinter).balance;
        assertEq(contractBalance, 0);
    }

    function test_FeeIsCollectedOnPrint() public {
        uint256 currentBalance = address(this).balance;
        string memory tokenURI = "https://example.com";
        vm.deal(user, fee);
        vm.prank(user);
        nftPrinter.printNFT{value: fee}(user, tokenURI);

        assertEq(address(nftPrinter).balance, 0);
        assertEq(address(this).balance, currentBalance + fee);
    }

    function test_FeeIsCollectedOnBuy() public {
        string memory tokenURI = "https://example.com";
        uint256 price = 10_000_000 gwei;
        uint256 bips = 100;
        uint256 currentBalance = address(this).balance;

        nftPrinter.setListingFeeBips(bips);

        vm.deal(user, fee*10);

        vm.startPrank(user);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(user, tokenURI);
        nftPrinter.setListing(tokenId, price);
        nftPrinter.buyListing{value: price}(tokenId);
        vm.stopPrank();

        assertEq(address(nftPrinter).balance, 0);
        assertEq(address(this).balance, currentBalance + fee + ((price * bips) / 10_000));
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
        nftPrinter.setMintFee(0 gwei);
        assertEq(nftPrinter.mintFee(), 0 gwei);
    }

    function test_ListingIsDeletedOffMarketAfterSale() public {
        string memory tokenURI = "https://example.com";
        uint256 tokenId = nftPrinter.printNFT{value: fee}(address(this), tokenURI);
        nftPrinter.setListing(tokenId, fee);
        nftPrinter.buyListing{value: fee}(tokenId);

        vm.expectRevert("No listing found for that token ID");
        nftPrinter.buyListing{value: fee}(tokenId);
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

    function test_BuyerMustPayAtLeastPrice() public {
        address buyer = address(2);
        vm.deal(buyer, fee * 2);
        address seller = address(3);
        vm.deal(seller, fee);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(seller, "https://example.com");
        vm.prank(seller);
        nftPrinter.setListing(tokenId, fee);

        vm.prank(buyer);
        vm.expectRevert("Must pay at least the price of the listing");
        nftPrinter.buyListing{value: 1}(tokenId);
    }

    function test_BuyerCannotBuyNFTWithoutListing() public {
        address buyer = address(2);
        vm.deal(buyer, fee * 2);
        address seller = address(3);
        vm.deal(seller, fee);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(seller, "https://example.com");

        vm.prank(buyer);
        vm.expectRevert("No listing found for that token ID");
        nftPrinter.buyListing{value: 0}(tokenId);
    }

    function test_SellerCanRemoveListing() public {
        uint256 tokenId = nftPrinter.printNFT{value: fee}(address(this), "https://example.com");

        nftPrinter.setListing(tokenId, fee);
        nftPrinter.removeListing(tokenId);

        vm.expectRevert("No listing found for that token ID");
        nftPrinter.getListing(tokenId);
    }

    function test_NonSellerCannotRemoveListing() public {
        address buyer = address(2);
        vm.deal(buyer, fee * 2);
        uint256 tokenId = nftPrinter.printNFT{value: fee}(address(this), "https://example.com");
        nftPrinter.setListing(tokenId, fee);

        vm.expectRevert("Must be token owner to remove listing");
        vm.prank(buyer);
        nftPrinter.removeListing(tokenId);
    }
}
