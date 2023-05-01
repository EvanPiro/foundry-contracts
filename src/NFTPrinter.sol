pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "forge-std/console.sol";

contract NFTPrinter is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("Prints", "PRNTS") {}

    function printNFT(string memory tokenURI) public returns (uint256) {
        uint256 newID = _tokenIds.current();
        _mint(msg.sender, newID);
        _setTokenURI(newID, tokenURI);
        _tokenIds.increment();
        return newID;
    }
}
