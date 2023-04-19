// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ITreasury.sol";

contract Market is AccessControl {
    using SafeERC20 for ERC20;

    bytes32 public constant OPERATOR = keccak256("OPERATOR");
    bytes32 public constant WHITELISTED_ADDRESS = keccak256("WHITELISTED_ADDRESS");
    bool private inited = false;

    IERC20 public currency;

    ITreasury public productTreasury;
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
        bool permissionLess; // true = igniring whitelist
        uint256 totalRaised;
    }

    mapping(uint256 => MarketInfo) markets;

    /* constructor */
    function initialize (address _currency, 
                address _productTreasury,
                address _currencyTreasury) public {
        require (!inited, "already inited");                    
        _setupRole(OPERATOR, msg.sender);
        _setupRole(WHITELISTED_ADDRESS, msg.sender);
        currency = IERC20(_currency);
        productTreasury = ITreasury(_productTreasury);
        currencyTreasury = _currencyTreasury;
        marketsCount = 0;
        inited = true;
    }

    // @dev
    // Market selling a structural note contains treasury notes in a predetermined ratio 
    //
    // refactor to struct
    function deployMarket(uint256 _price,
                       uint256 _minOrderSize,
                       uint256 _maxOrderSize,
                       uint256 _tgeRatio, 
                       uint256 _start,
                       uint256 _cliff,
                       uint256 _duration,
                       uint256 _slicePeriod,
                       bool _revocable,
                       bool _permissionLess
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
            _permissionLess,
            0
        );
        
        marketsCount += 1;

    }

    function migrateUser(uint256 _market, uint256 _amount, address _beneficiary) public {
        require(hasRole(OPERATOR, msg.sender), "Caller is not an operator");
        require(marketsCount > _market, "Incorect market");
        require(markets[_market].minOrderSize <= _amount && markets[_market].maxOrderSize >= _amount, "Min or max order size limit");

        (uint256 tgeAmount, uint256 vestingAmount) = calculateOrderSize(_market, _amount);
        productTreasury.withdrawTo(tgeAmount, _beneficiary);
        _migrateUser(_market, vestingAmount, _beneficiary);
    }

    function buy(uint256 _market, uint256 _amount, address _beneficiary) public {
        require(marketsCount > _market, "Incorect market");
        if (!markets[_market].permissionLess) {
            require(hasRole(WHITELISTED_ADDRESS, _beneficiary), "User is not in white list");
        }
        require(markets[_market].minOrderSize <= _amount && markets[_market].maxOrderSize >= _amount, "Min or max order size limit");
        currency.transferFrom(msg.sender, currencyTreasury, calculateOrderPrice(_market, _amount));
        (uint256 tgeAmount, uint256 vestingAmount) = calculateOrderSize(_market, _amount);
        productTreasury.withdrawTo(tgeAmount, _beneficiary);
        _migrateUser(_market, vestingAmount, _beneficiary);
    }

    function _migrateUser(uint256 _market, uint256 _amount, address _beneficiary) private {
        productTreasury.createVestingSchedule(_beneficiary,
                                            markets[_market].start, 
                                            markets[_market].cliff, 
                                            markets[_market].duration, 
                                            markets[_market].slicePeriod, 
                                            markets[_market].revocable,
                                            _amount,
                                            _market);
        markets[_market].totalRaised += _amount;
    }

    function calculateOrderSize(uint256 _market, uint256 _amount) public view returns(uint256 _tgeAmount, uint256 _vestingAmount) {
        require(marketsCount > _market, "Incorect market");

        _tgeAmount = _amount * markets[_market].tgeRatio / 1e6;
        _vestingAmount = _amount - _tgeAmount;

    }


    function calculateOrderPrice(uint256 _market, uint256 _amount) public view returns( uint256 _price ) {
        _price = _amount * markets[_market].price / 1e3; // price = price*1000, 0.01 = 10
    }

    // @dev call getIndexCount, and claim in loop for all indexes
    function claimForIndex(uint256 _index, uint256 marketId) public {
            bytes32 vestingCalendarId = productTreasury.computeVestingScheduleIdForAddressAndIndex(msg.sender, _index);
            uint256 avaibleForClaim = productTreasury.computeReleasableAmount(vestingCalendarId, marketId);
            productTreasury.release(vestingCalendarId, avaibleForClaim, marketId);

    }

    function avaibleToClaim(address _benefeciary, uint256 marketId) public view returns( uint256 _avaible ) {
        uint256 vestingScheduleCount = productTreasury.getVestingSchedulesCountByBeneficiary(msg.sender, marketId);
        bytes32 vestingCalendarId;
        uint256 avaibleForClaim = 0;
        for (uint256 calendarNumber = 0; calendarNumber < vestingScheduleCount; calendarNumber++) {
            vestingCalendarId = productTreasury.computeVestingScheduleIdForAddressAndIndex(msg.sender, calendarNumber); //TODO add count
            avaibleForClaim += productTreasury.computeReleasableAmount(vestingCalendarId, marketId);
        }
        return avaibleForClaim;
    }

    event Log(string msg, uint256 data);
    event LogBytes(string msg, bytes32 data);
    // @dev Use careful - O(n) function
    function claim(uint256 marketId) public {
            uint256 vestingScheduleCount = productTreasury.getVestingSchedulesCountByBeneficiary(msg.sender, marketId);
            emit Log("vestingScheduleCount", vestingScheduleCount);
            bytes32 vestingCalendarId;
            uint256 avaibleForClaim;
            for (uint256 calendarNumber = 0; calendarNumber < vestingScheduleCount; calendarNumber++) {
                vestingCalendarId = productTreasury.computeVestingScheduleIdForAddressAndIndex(msg.sender, calendarNumber); //TODO add count
                emit LogBytes("vestingCalendarId", vestingCalendarId);
                avaibleForClaim = productTreasury.computeReleasableAmount(vestingCalendarId, marketId);
                emit Log("avaibleForClaim", avaibleForClaim);
                productTreasury.release(vestingCalendarId, avaibleForClaim, marketId);
            }


    }

    function getVestingScheduleForIndex(uint256 _index, address _benefeciary, uint256 marketId) public view returns(ITreasury.VestingSchedule memory) {
        return productTreasury.getVestingScheduleByAddressAndIndex(_benefeciary, _index, marketId);
    }

    // @dev Use careful - O(n) function
    function getVestingSchedules(address _benefeciary, uint256 marketId) public view returns(ITreasury.VestingSchedule[] memory){
        uint256 vestingScheduleCount = productTreasury.getVestingSchedulesCountByBeneficiary(_benefeciary, marketId);
        ITreasury.VestingSchedule[] memory vestingSchedules = new ITreasury.VestingSchedule[](vestingScheduleCount);
        for (uint256 calendarNumber = 0; calendarNumber < vestingScheduleCount; calendarNumber++) {
                vestingSchedules[calendarNumber] = productTreasury.getVestingScheduleByAddressAndIndex(_benefeciary, calendarNumber, marketId);
        }
        return vestingSchedules;
    }

    function getIndexCount(uint256 marketId) public view returns(uint256) {
        return productTreasury.getVestingSchedulesCountByBeneficiary(msg.sender, marketId);
    }

    function getMarketInfo(uint256 _index) public view returns(MarketInfo memory) {
        return markets[_index];

    }


}

