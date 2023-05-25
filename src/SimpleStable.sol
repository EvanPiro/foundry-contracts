// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Notary contract registers and authenticates Positions.
 *
 * This contract allows users to open positions, which can be verified
 * during the minting of the stablecoin.
 */
contract Notary is Ownable {
    mapping(address => bool) public isValidPosition;

    event PositionOpened(address positionAddress);

    uint256 public minRatio;
    address public priceFeedAddress;
    address public coinAddress;

    bool public activated;

    modifier isActivated() {
        require(activated, "Notary has not be activated");
        _;
    }

    constructor(uint256 _minRatio, address _priceFeedAddress) public {
        minRatio = _minRatio;
        priceFeedAddress = _priceFeedAddress;
    }

    /**
     * @dev Activates the notary by providing the address of a token contract
     * that has been configured to reference this address.
     */
    function activate(address _coinAddress) public onlyOwner {
        // @Todo check for notary address, investigate recursive implications.
        coinAddress = _coinAddress;
    }

    /**
     * @dev Opens a position for a specified vault owner address.
     */
    function openPosition(address ownerAddress) public isActivated returns (address positionAddress) {
        Position position = new Position(minRatio, priceFeedAddress, coinAddress, ownerAddress);
        address positionAddress = address(position);

        isValidPosition[positionAddress] = true;

        emit PositionOpened(positionAddress);
        return address(positionAddress);
    }
}

/**
 * @dev Position contract manages a tokenized debt position.
 *
 * This contract provides the means for an account to manage their debt position
 * through enforcing adequate collatoralization while withdrawing debt tokens.
 */
contract Position is Ownable {
    uint256 public immutable minRatio;
    PriceFeed private immutable priceFeed;
    Coin private immutable coin;
    uint256 debt;

    constructor(uint256 _minRatio, address _priceFeedAddress, address _coinAddress, address _owner) public {
        minRatio = _minRatio;
        priceFeed = PriceFeed(_priceFeedAddress);
        coin = Coin(_coinAddress);
        transferOwnership(_owner);
    }

    /**
     * @dev Returns true if the contract's debt position can increase by a specified amount.
     */
    function canTake(uint256 _moreDebt) public returns (bool) {
        uint256 col = address(this).balance;
        uint256 price = priceFeed.price();
        return ((col * price) / (debt + _moreDebt)) >= minRatio;
    }

    function take(uint256 _moreDebt) public onlyOwner {
        coin.mint(address(this), _moreDebt);
    }
}

/**
 * @dev Coin contract manages the supply of the stable coin
 *
 * This contract is simple ER20 token contract with constraints on minting, where minting
 * is limited to a Notary registered Position that is above the mininum collateralization
 * ratio.
 */
contract Coin is ERC20 {
    Notary notary;

    constructor(address _notaryAddress) ERC20("Coin", "coin") {
        notary = Notary(_notaryAddress);
    }

    function mint(address _positionAddress, uint256 _moreDebt) public {
        require(notary.isValidPosition(_positionAddress), "Caller is not authorized to mint");
        Position position = Position(_positionAddress);

        require(position.canTake(_moreDebt), "Position cannot take more debt");

        _mint(_positionAddress, _moreDebt);
    }
}

/**
 * @dev PriceFeed contract for providing price for determining a position's collatoralization
 * ratio.
 *
 * This contract implements a price feed, where the price is pulled from chainlink and saved to
 * the contract state.
 */
contract PriceFeed {
    AggregatorV3Interface internal priceFeed;
    uint256 public price;

    constructor(address aggregatorAddress) {
        priceFeed = AggregatorV3Interface(aggregatorAddress);
    }

    /**
     * Returns the latest price.
     */
    function refreshPrice() public {
        // prettier-ignore
        (
            /* uint80 roundID */
            ,
            int256 _price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        price = uint256(_price);
    }
}
