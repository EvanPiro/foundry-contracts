pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "forge-std/console.sol";

contract NFTPrinter is Ownable, ERC721("rando", "rando") {

    function printNFT(uint cid) public {
        _mint(msg.sender, cid);
    }
}
