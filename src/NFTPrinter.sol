pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/utils/Address.sol";

contract NFTPrinter is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC721URIStorageUpgradeable {
    using Counters for Counters.Counter;

    uint256 public mintFee;
    uint256 public listingFeeBips;
    mapping(uint256 => uint256) listing;

    Counters.Counter private _tokenIds;

    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) public initializer {
        __ERC721_init("clicknmint", "CNM");
        __Ownable_init();
        transferOwnership(owner);
        mintFee = 10_000_000 gwei;
        listingFeeBips = 50;
    }

    /**
     * @dev Mints a token for the provided recipient and sets the provided
     * URI. This requires that a fee amount is sent.
     */
    function printNFT(address recipient, string memory tokenURI) external payable returns (uint256) {
        require(msg.value >= mintFee, "Fee of 0.01 must be added to transaction");
        Address.sendValue(payable(owner()), msg.value);
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

    function removeListing(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId), "Must be token owner to remove listing");
        delete listing[tokenId];
        approve(address(0), tokenId);
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
        Address.sendValue(payable(owner()), fee);
        _transfer(nftOwner, msg.sender, tokenId);
        delete listing[tokenId];
    }
}
