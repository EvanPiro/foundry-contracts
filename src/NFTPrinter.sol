pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "./INFTPrinter.sol";

contract NFTPrinter is ERC721URIStorage, INFTPrinter {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("Prints", "PRNTS") {}

    function printNFT(address owner, string memory tokenURI) external returns (uint256) {
        uint256 newID = _tokenIds.current();
        _mint(owner, newID);
        _setTokenURI(newID, tokenURI);
        _tokenIds.increment();
        return newID;
    }
}
