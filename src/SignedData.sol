pragma solidity ^0.8.16;

import "openzeppelin-contracts/utils/cryptography/ECDSA.sol";


using ECDSA for bytes32;

/**
 *
 */
contract SignedData {
    address public _signer;
    bytes32 public _data;

    constructor(address signer) public {
        _signer = signer;
    }

    function isVerifiedData(bytes32 data, bytes memory sig) public returns(bool) {
        return keccak256(data)
            .toEthSignedMessageHash()
            .recover(sig) == _signer;
    }
}
