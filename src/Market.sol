// contracts/Market.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../src/treasury.sol";

contract Market is AccessControl {
    using SafeERC20 for ERC20;

    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    IERC20 public currency;

    Treasury public productTreasury;
    address public currencyTreasury;
    uint256 public marketsCount;

    struct MarketInfo {
        uint256 tgeRatio;
        uint256 start;// = block.timestamp;//1678896515;//block.timestamp; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/ 1678896515
        uint256 cliff;        
        uint256 duration; 
        uint256 slicePeriod;
        bool revocable;
        uint256 price; 
        uint256 minOrderSize;
        uint256 maxOrderSize;
        bool permisionLess; // true = igniring whitelist
        //mapping (address => bool) whitelist;
    }

    mapping(uint256 => MarketInfo) markets;

    constructor(address _currency, 
                address _productTreasury){
                    _setupRole(OPERATOR, msg.sender);
                    currency = IERC20(_currency);
                    productTreasury = ITreasury(_productTreasury);
                    //currency = IERC20(currency);
                    marketsCount = 0;

    }

    // @dev
    // Market selling a structural note contains treasury notes in a predetermined ratio 
    // 
    function deployMarket(uint256 _price,
                       uint256 _minOrderSize,
                       uint256 _maxOrderSize,
                       uint256 _tgeRatio, 
                       uint256 _start,
                       uint256 _cliff,
                       uint256 _duration,
                       uint256 _slicePeriod,
                       bool _revocable,
                       bool _permisionLess
                       ) public {
        require(hasRole(OPERATOR, msg.sender), "Caller is not an operator");

        markets[marketsCount] = MarketInfo(
            _tgeRatio,
            _start,
            _cliff,
            _duration,
            _slicePeriod,
            _revocable,
            _price,
            _minOrderSize,
            _maxOrderSize,
            _permisionLess
        );
        
        marketsCount += 1;

    }

    function migrateUser(uint256 _market, uint256 _amount, address _benefeciary) public {
        require(hasRole(OPERATOR, msg.sender), "Caller is not an operator");
        require(marketsCount > _market, "Incorect market");
        require(markets[_market].minOrderSize >= _amount && markets[_market].maxOrderSize <= _amount, "Min or max order size limit");

        (uint256 tgeAmount, uint256 vestingAmount) = calculateOrderSize(_market, _amount);
        productTreasury.withdrawTo(tgeAmount, _benefeciary);
        _migrateUser(_market, vestingAmount, _benefeciary);
    }

    function buy(uint256 _market, uint256 _amount, address _benefeciary) public {
        require(marketsCount > _market, "Incorect market");
        require(markets[_market].minOrderSize >= _amount && markets[_market].maxOrderSize <= _amount, "Min or max order size limit");
        currency.transferFrom(msg.sender, currencyTreasury, _amount * markets[_market].price);
        (uint256 tgeAmount, uint256 vestingAmount) = calculateOrderSize(_market, _amount);
        productTreasury.withdrawTo(tgeAmount, _benefeciary);
        _migrateUser(_market, vestingAmount, _benefeciary);
    }

    function _migrateUser(uint256 _market, uint256 _amount, address _benefeciary) private {
        productTreasury.createVestingSchedule(_benefeciary, 
                                            markets[_market].start, 
                                            markets[_market].cliff, 
                                            markets[_market].duration, 
                                            markets[_market].slicePeriod, 
                                            markets[_market].revocable,
                                            _amount);


    }

    function calculateOrderSize(uint256 _market, uint256 _amount) public view returns(uint256 _tgeAmount, uint256 _vestingAmount) {
        require(marketsCount > _market, "Incorect market");

        _tgeAmount = _amount * markets[_market].tgeRatio / 1e6; // 100*3725/1000000
        _vestingAmount = _amount - _tgeAmount;

    }


    function calculateOrderPrice(uint256 _market, uint256 _amount) public view returns( uint256 _price ) {
        _price = _amount * markets[_market].price;
    }

    
    function claimForAddressAndIndex(address _benefeciary, uint256 _index) public {
            bytes32 vestingCalendarId = productTreasury.computeVestingScheduleIdForAddressAndIndex(address(this), _index);
            uint256 avaibleToClaim = productTreasury.computeReleasableAmount(vestingCalendarId);
            productTreasury.release(vestingCalendarId, avaibleToClaim);

    }
/*
    function claimForAddress() {

    }

    function getVestingScheduleForAddressAndIndex() {

    }

    function getVestingSchedulesForAddress() {

    }
*/
}


/*

interface ITreasury {

    function withdrawTo(uint256 amount,
        address beneficiary) external;

    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount
    ) external;

    function computeVestingScheduleIdForAddressAndIndex(
        address holder, 
        uint256 index
    ) external;

    function computeReleasableAmount(
        bytes32 vestingScheduleId 
    ) external;

}


*/



    
