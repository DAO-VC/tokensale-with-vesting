// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ITreasury {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Released(uint256 amount);
    event Revoked();

    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        bool revocable;
        uint256 amountTotal;
        uint256 initAmount;
        uint256 released;
        bool revoked;
        uint256 roundId;
    }

    function computeNextVestingScheduleIdForHolder(address holder) external view returns (bytes32);
    function computeReleasableAmount(bytes32 vestingScheduleId) external view returns (uint256);
    function computeVestingScheduleIdForAddressAndIndex(address holder, uint256 index)
        external
        pure
        returns (bytes32);
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount,
        uint256 roundId
    ) external;
    function getLastVestingScheduleForHolder(address holder) external view returns (VestingSchedule memory);
    function getToken() external view returns (address);
    function getVestingIdAtIndex(uint256 index) external view returns (bytes32);
    function getVestingSchedule(bytes32 vestingScheduleId) external view returns (VestingSchedule memory);
    function getVestingScheduleByAddressAndIndex(address holder, uint256 index)
        external
        view
        returns (VestingSchedule memory);
    function getVestingSchedulesCount() external view returns (uint256);
    function getVestingSchedulesCountByBeneficiary(address _beneficiary) external view returns (uint256);
    function getVestingSchedulesTotalAmount() external view returns (uint256);
    function getWithdrawableAmount() external view returns (uint256);
    function owner() external view returns (address);
    function release(bytes32 vestingScheduleId, uint256 amount) external;
    function renounceOwnership() external;
    function revoke(bytes32 vestingScheduleId) external;
    function transferOwnership(address newOwner) external;
    function withdraw(uint256 amount) external;
    function withdrawTo(uint256 amount, address beneficiary) external;
}
