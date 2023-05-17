pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract NFTPrinter is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    uint256 public mintFee = 10_000_000 gwei;
    uint256 public listingFeeBips = 50;
    mapping(uint256 => uint256) listing;

    Counters.Counter private _tokenIds;

    constructor() ERC721("clicknmint", "CNM") {}

    /**
     * @dev Mints a token for the provided recipient and sets the provided
     * URI. This requires that a fee amount is sent.
     */
    function printNFT(address recipient, string memory tokenURI) external payable returns (uint256) {
        require(msg.value >= mintFee, "Fee of 0.01 must be added to transaction");
        uint256 newID = _tokenIds.current();
        _mint(recipient, newID);
        _setTokenURI(newID, tokenURI);
        _tokenIds.increment();
        return newID;
    }

    function setMintFee(uint256 _fee) external onlyOwner {
        mintFee = _fee;
    }

    function setListingFeeBips(uint256 _bips) external onlyOwner {
        listingFeeBips = _bips;
    }

    function setListing(uint256 tokenId, uint256 price) external {
        require(msg.sender == ownerOf(tokenId), "Must be token owner to set listing");
        require(price > 0, "Listing price must be greater than 0");
        approve(address(this), tokenId);
        listing[tokenId] = price;
    }

    function getListing(uint256 tokenId) external view returns (uint256) {
        require(listing[tokenId] != 0, "No listing found for that token ID");
        return listing[tokenId];
    }

    function buyListing(uint256 tokenId) external payable nonReentrant {
        uint256 price = this.getListing(tokenId);
        address nftOwner = ownerOf(tokenId);
        require(msg.value >= price, "Must pay at least the price of the listing");
        uint256 fee = (price * listingFeeBips) / 10_000;
        uint256 payment = price - fee;

        payable(ownerOf(tokenId)).call{value: payment}("");
        _transfer(nftOwner, msg.sender, tokenId);
        delete listing[tokenId];
    }

    /**
     * @dev `collect` handles the sending of collected fees to the owner account.
     * This can be called by any user.
     */
    function collect() external nonReentrant {
        payable(owner()).call{value: address(this).balance}("");
    }
}
