pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./INFTPrinter.sol";


contract NFTPrinter is ERC721URIStorage, INFTPrinter, Ownable {
    using Counters for Counters.Counter;
    uint256 public fee = 10_000_000 gwei;

    Counters.Counter private _tokenIds;

    constructor() ERC721("clicknmint", "CLMT") {}

    /**
     * @dev Mints a token for the provided recipient and sets the provided
     * URI. This requires that a fee amount is sent.
     */
    function printNFT(address recipient, string memory tokenURI) external payable returns (uint256) {
        require(msg.value >= fee, "Fee of 0.01 must be added to transaction");
        uint256 newID = _tokenIds.current();
        _mint(recipient, newID);
        _setTokenURI(newID, tokenURI);
        _tokenIds.increment();
        return newID;
    }

    /**
     * @dev `collect` handles the sending of collected fees to the owner account.
     * This can be called by any user.
     */
    function collect() external {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
}
