pragma solidity ^0.8.10;

interface Market {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        bool revocable;
        uint256 amountTotal;
        uint256 released;
        bool revoked;
    }

    struct MarketInfo {
        uint256 tgeRatio;
        uint256 start;
        uint256 cliff;
        uint256 duration;
        uint256 slicePeriod;
        bool revocable;
        uint256 price;
        uint256 minOrderSize;
        uint256 maxOrderSize;
        bool permisionLess;
    }

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function OPERATOR() external view returns (bytes32);
    function avaibleToClaim(uint256 _index, address _benefeciary) external view returns (uint256 _avaible);
    function buy(uint256 _market, uint256 _amount, address _benefeciary) external;
    function calculateOrderPrice(uint256 _market, uint256 _amount) external view returns (uint256 _price);
    function calculateOrderSize(uint256 _market, uint256 _amount)
        external
        view
        returns (uint256 _tgeAmount, uint256 _vestingAmount);
    function claim() external;
    function claimForIndex(uint256 _index) external;
    function currency() external view returns (address);
    function currencyTreasury() external view returns (address);
    function deployMarket(
        uint256 _price,
        uint256 _minOrderSize,
        uint256 _maxOrderSize,
        uint256 _tgeRatio,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriod,
        bool _revocable,
        bool _permisionLess
    ) external;
    function getIndexCount() external view returns (uint256);
    function getMarketInfo(uint256 _index) external view returns (MarketInfo memory);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function getVestingScheduleForIndex(uint256 _index, address _benefeciary)
        external
        view
        returns (VestingSchedule memory);
    function getVestingSchedules(address _benefeciary) external view returns (VestingSchedule[] memory);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function marketsCount() external view returns (uint256);
    function migrateUser(uint256 _market, uint256 _amount, address _benefeciary) external;
    function productTreasury() external view returns (address);
    function renounceRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}