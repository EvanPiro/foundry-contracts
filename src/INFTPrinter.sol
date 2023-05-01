pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface INFTPrinter is IERC721 {
    function printNFT(address owner, string memory tokenURI) external returns (uint256);
}