// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Notary {
    mapping (address => bool) public positions;

    event PositionOpened(address positionAddress);

    uint256 public cRatio;
    address public priceOracleAddress;

    constructor(uint256 _cRatio, address _priceFeed) public {
        cRatio = _cRatio;
        priceFeed = _priceFeed;
    }

    function openPosition() public returns(address positionAddress) {
        position = new Position();
        address positionAddress = address(position);
        emit PositionOpened(positionAddress);
        return address(positionAddress);
    }
}

contract Position {
    uint256 immutable public cRatio;
    address immutable public priceOracleAddress;
    uint256 debt;

    constructor(uint256 _cRatio, address _priceFeed) public {
        cRatio = _cRatio;
        priceFeed = _priceFeed;
    }

    /**
     * @dev Returns true if the contract's debt position can increase by a specified amount.
     */
    function canTake(uint256 _moreDebt) public returns(bool) {
        uint256 col = address(this).balance;
        return (col / (debt + _moreDebt)) > cRatio;
    }

}
contract Coin is ERC20 {
    address notaryAddress;
    constructor(address _notaryAddress) ERC20("Coin", "coin") {
        notaryAddress = _notaryAddress;
    }

    function mint(address _positionAddress, uint256 _moreDebt) {
        Position position = Position(_positionAddress);
        require (position.canTake(_moreDebt), "Position cannot take more debt");

        _mint(_positionAddress, _amount);
    }
}