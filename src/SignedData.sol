pragma solidity ^0.8.16;

import "forge-std/console.sol";

/**
 * @title Verifiably Signed On-Chain Data
 * @author Evan Piro
 * @notice You can use this contract to support validating externally ECDSA
 * signed data on-chain without needing the signer. The contract takes the public
 * key of the signer and uses it to check the signature.
 * @dev This contract is designed to be extended, utilizing the isVerifiedData
 * function verify against a signature.
 */
contract SignedData {
    address public _signer;

    /*
     * @dev Initialize contract with the address of account for which this contract will be
     * checking the signature.
     */
    constructor(address signer) {
        _signer = signer;
    }

    /*
     * @dev Check if data has been signed from a signature created by the account _signer.
     * @params The data that was signed and the signature (v, r, s) that was produced by an
     * ECDSA signing function with the _signer private key.
     * @return Whether or not the data was actually signed by the provided integer.
     */
    function isVerifiedData(bytes memory data, uint8 v, bytes32 r, bytes32 s) public virtual returns (bool) {
        bytes32 hash = keccak256(data);
        return ecrecover(hash, v, r, s) == _signer;
    }
}
