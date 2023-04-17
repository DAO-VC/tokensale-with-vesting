// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Treasury.sol";

contract TreasuryTest is Test {
    Treasury public treasury;
    // dev: any erc20 token for testing vesting calendar on mainnet forking
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F;//
    // dev: quote asset for testing tokensale on mainnet is WETH
    //address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // binance account with 3 billions USDC
    IERC20 private constant usdc = IERC20(USDC);

    function setUp() public {
        // get usdc from usdc_whale
        vm.startPrank(USDC_WHALE);
        //vm.expectRevert("Ownable: caller is not the owner");
        usdc.transfer(address(this), 5000 * 1e6);
        vm.stopPrank();

        // instance vault with vested token
        treasury = new Treasury(USDC);
        //counter.setNumber(0);

        // transfer USDC to vesting tresury
        usdc.transfer(address(treasury), usdc.balanceOf(address(this)));
        console.log('Balance of tresury before test',usdc.balanceOf(address(treasury)));

    }

    function testSingleVestingSlice() public {

        uint256 start = block.timestamp;//1678896515;//block.timestamp; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/ 1678896515
        uint256 cliff = 0;
        uint256 duration = 604800; // seconds in week
        uint256 slicePeriodSeconds = 1;
        bool revocable = true;
        uint256 amount = 100 * 1e6; 

        uint256 calendarNumber = 0;

        console.log('Block number in starting', block.number);
        console.log('Timestamp', block.timestamp);

        treasury.createVestingSchedule(address(this), start, cliff, duration, slicePeriodSeconds, revocable, amount);

        console.log('Total vestings calendars', treasury.getVestingSchedulesCount());

        uint256 vestingScheduleCount = treasury.getVestingSchedulesCountByBeneficiary(address(this));
        console.log('Total vestings calendars for current user', vestingScheduleCount);

        
        //for (uint256 i = 0; i <= vestingScheduleCount; i++) {
        bytes32 vestingCalendarId = treasury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);

        //console.logBytes32(tresury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber));
        //}

        //console.log('Vesting callendar index', tresury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber));

        //uint256 availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
        console.log('available amount for claim from tresury before warp', treasury.computeReleasableAmount(vestingCalendarId));
        
        //vm.roll(block.number + 100);
        vm.warp(block.timestamp + duration + 1);

        uint256 availableToClaim = treasury.computeReleasableAmount(vestingCalendarId);
        console.log('available amount for claim from tresury after warp', availableToClaim);
        
        //console.log('Block number 2', block.number);
        //console.log('Timestamp 2', block.timestamp);

        treasury.release(vestingCalendarId, availableToClaim);

        console.log('balance of test user after release tokens', usdc.balanceOf(address(this)));

        
        console.log('available amount for claim from tresury after release', treasury.computeReleasableAmount(vestingCalendarId));




        //counter.increment();
        //assertEq(counter.number(), 1);
    }

    function testDoubleVestingSlice() public {
        // first calendar for 1 week 
        uint256 start = block.timestamp;//1678896515;//block.timestamp; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/ 1678896515
        uint256 cliff = 0;
        uint256 duration = 1 weeks; 
        uint256 slicePeriod = 1 weeks;
        bool revocable = true;
        uint256 amount = 10 * 1e6; 
        treasury.createVestingSchedule(address(this), start, cliff, duration, slicePeriod, revocable, amount);

        start = block.timestamp;//1678896515;//block.timestamp; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/ 1678896515
        cliff = 0;
        duration = 4 weeks; // 4 weeks
        slicePeriod = 1 weeks;
        revocable = true;
        amount = 200 * 1e6; 
        treasury.createVestingSchedule(0xCc419cB156Ff14aeb77ccA915503E0a2A1168796, start, cliff, duration, slicePeriod, revocable, amount);

        // second calendar for 4 week vesting and releasing 4 times
        start = block.timestamp;//1678896515;//block.timestamp; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/ 1678896515
        cliff = 0;
        duration = 4 weeks; // 4 weeks
        slicePeriod = 1 weeks;
        revocable = true;
        amount = 100 * 1e6; 
        treasury.createVestingSchedule(address(this), start, cliff, duration, slicePeriod, revocable, amount);
        //counter.setNumber(x);
        //assertEq(counter.number(), x);
        console.log('===========MASTER DATA============');
        console.log('Total vestings calendars', treasury.getVestingSchedulesCount());
        uint256 vestingScheduleCount = treasury.getVestingSchedulesCountByBeneficiary(address(this));
        console.log('Total vestings calendars for current user', vestingScheduleCount);
        console.log('Block number in starting', block.number);
        console.log('Timestamp', block.timestamp);
        console.log('===========TX DATA============');
        console.log('User balance', usdc.balanceOf(address(this)));
        vm.warp(start + 1 weeks);
        computeAndReleaseMultiplyCallendars(vestingScheduleCount);
        console.log('User balance', usdc.balanceOf(address(this)));

        vm.warp(start + 2 weeks);
        computeAndReleaseMultiplyCallendars(vestingScheduleCount);
        console.log('User balance', usdc.balanceOf(address(this)));

        vm.warp(start + 3 weeks);
        computeAndReleaseMultiplyCallendars(vestingScheduleCount);
        console.log('User balance', usdc.balanceOf(address(this)));

        vm.warp(start + 4 weeks);
        computeAndReleaseMultiplyCallendars(vestingScheduleCount);
        console.log('User balance', usdc.balanceOf(address(this)));

        vm.warp(start + 5 weeks);
        computeAndReleaseMultiplyCallendars(vestingScheduleCount);
        console.log('User balance', usdc.balanceOf(address(this))); 

        /*
        vm.warp(start + cliff);
        
        
        for (uint256 calendarNumber = 0; calendarNumber < vestingScheduleCount; calendarNumber++) {
            vestingCalendarId = tresury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);
            availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
            console.log('available %i', tresury.computeReleasableAmount(vestingCalendarId));
            tresury.release(vestingCalendarId, availableToClaim);
        }



        bytes32 vestingCalendarId = tresury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);
        console.log('available 1', tresury.computeReleasableAmount(vestingCalendarId));

        vm.warp(start + cliff + slicePeriodSeconds);
        console.log('Timestamp', block.timestamp);

        uint256 availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
        console.log('available 2', availableToClaim);
        tresury.release(vestingCalendarId, availableToClaim);
        console.log('USER ACC', usdc.balanceOf(address(this)));

        vm.warp(start + cliff + 2*slicePeriodSeconds);
        console.log('Timestamp', block.timestamp);

        availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
        console.log('available 3', availableToClaim);
        tresury.release(vestingCalendarId, availableToClaim);
        console.log('USER ACC', usdc.balanceOf(address(this)));

        vm.warp(start + cliff + 3*slicePeriodSeconds);
        console.log('Timestamp', block.timestamp);

        availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
        console.log('available 4', availableToClaim);
        tresury.release(vestingCalendarId, availableToClaim);
        console.log('USER ACC', usdc.balanceOf(address(this)));


        vm.warp(start + cliff + 4*slicePeriodSeconds);
        console.log('Timestamp', block.timestamp);

        availableToClaim = tresury.computeReleasableAmount(vestingCalendarId);
        console.log('available 5', availableToClaim);
        tresury.release(vestingCalendarId, availableToClaim);
        console.log('USER ACC', usdc.balanceOf(address(this)));
        */

    }

    function computeAndReleaseMultiplyCallendars(uint256 callendarCount) public {
        bytes32 vestingCalendarId;
        uint256 availableToClaim;
        for (uint256 calendarNumber = 0; calendarNumber < callendarCount; calendarNumber++) {
            vestingCalendarId = treasury.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);
            availableToClaim = treasury.computeReleasableAmount(vestingCalendarId);
            console.log('available %i', availableToClaim);
            treasury.release(vestingCalendarId, availableToClaim);
        }
    }
}
