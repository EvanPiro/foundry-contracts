pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/SignedData.sol";
import "../src/NFTPrinter.sol";
import "../src/NFTPrinterV2.sol";
import "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeNFTPrinter is Test {
    NFTPrinter nftPrinterImpl;
    NFTPrinterV2 nftPrinterV2Impl;
    address user = address(3);
    address owner = address(2);

    function setUp() public {
        nftPrinterImpl = new NFTPrinter();
        nftPrinterV2Impl = new NFTPrinterV2();

    }

    function test_ProxyLoadedFromAddress() public {
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(nftPrinterImpl), address(this), abi.encodeWithSignature("initialize(address)", owner)
        );
        address payable proxyAddress = payable(address(proxy));

        TransparentUpgradeableProxy loadedProxy = TransparentUpgradeableProxy(proxyAddress);
        assertEq(proxy.implementation(), loadedProxy.implementation());

    }

    function test_UpgradesToV2() public {
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(nftPrinterImpl), address(this), abi.encodeWithSignature("initialize(address)", owner)
        );

        uint256 bips = 5555;
        NFTPrinter nftPrinter = NFTPrinter(address(proxy));

        vm.prank(owner);
        nftPrinter.setListingFeeBips(bips);

        proxy.upgradeTo(address(nftPrinterV2Impl));

        NFTPrinterV2 nftPrinterV2 = NFTPrinterV2(address(proxy));

        vm.startPrank(owner);

        nftPrinterV2.setUpdateTest(bips);
        assertEq(nftPrinterV2.listingFeeBips(), bips);
        assertEq(nftPrinterV2.updateTest(), bips);
        vm.stopPrank();
    }

}
