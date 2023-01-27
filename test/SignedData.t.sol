pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/SignedData.sol";

contract SignedDataTest is Test {
    SignedData signedData;

    function setUp() public {
        signedData = new SignedData(vm.addr(1));
    }

    function testIsVerifiedData() public {
        bytes memory message = "this is a test";

        bytes32 hash = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        assertTrue(signedData.isVerifiedData(message, v, r, s));
    }

    function testIsNotVerifiedData() public {
        bytes memory message = "this is a test";

        bytes32 hash = keccak256(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(2, hash);

        assertFalse(signedData.isVerifiedData(message, v, r, s));
    }
}
