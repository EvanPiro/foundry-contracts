pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/SignedData.sol";

contract SignedDataTest is Test {
    SignedData signedData;

    event DataUpdated(address sender);

    function setUp() public {
        signedData = new SignedData(vm.addr(1));
    }

    function testCannotAllowBadSign() public {
        vm.expectRevert(bytes("Data was not signed by verified account"));
        bytes memory message = "this is a test";
        bytes32 hash = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, hash);

        signedData.updateData(message, v, r, s);
    }

    function testUpdateData() public {
        vm.expectEmit(false, false, false, true);
        emit DataUpdated(address(this));
        bytes memory message = "this is a test";
        bytes32 hash = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        signedData.updateData(message, v, r, s);
        assertEq(message, signedData._data());
    }

    function testIsVerifiedData() public {
        bytes memory message = "this is a test";

        bytes32 hash = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        assertTrue(signedData.isVerifiedData(message, v, r, s));
    }
}
