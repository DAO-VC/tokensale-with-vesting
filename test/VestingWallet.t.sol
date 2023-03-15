// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VestingWallet.sol";

contract VestingWalletTest is Test {
    VestingWallet public wallet;
    // dev: any erc20 token for testing vesting calendar on mainnet forking
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F;//
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
        wallet = new VestingWallet(USDC);
        //counter.setNumber(0);

        // transfer USDC to vesting wallet
        usdc.transfer(address(wallet), 5000 * 1e6);
        console.log('Balance of vesting wallet before test',usdc.balanceOf(address(wallet)));

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

        wallet.createVestingSchedule(address(this), start, cliff, duration, slicePeriodSeconds, revocable, amount);

        console.log('Total vestings calendars', wallet.getVestingSchedulesCount());

        uint256 vestingScheduleCount = wallet.getVestingSchedulesCountByBeneficiary(address(this));
        console.log('Total vestings calendars for current user', vestingScheduleCount);

        
        //for (uint256 i = 0; i <= vestingScheduleCount; i++) {
        bytes32 vestingCalendarId = wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);

        //console.logBytes32(wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber));
        //}

        //console.log('Vesting callendar index', wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber));

        //uint256 avaibleToClaim = wallet.computeReleasableAmount(vestingCalendarId);
        console.log('Avaible amount for claim from wallet before warp', wallet.computeReleasableAmount(vestingCalendarId));
        
        //vm.roll(block.number + 100);
        vm.warp(block.timestamp + duration + 1);

        uint256 avaibleToClaim = wallet.computeReleasableAmount(vestingCalendarId);
        console.log('Avaible amount for claim from wallet after warp', avaibleToClaim);
        
        //console.log('Block number 2', block.number);
        //console.log('Timestamp 2', block.timestamp);

        wallet.release(vestingCalendarId, avaibleToClaim);

        console.log('balance of test user after release tokens',usdc.balanceOf(address(this)));

        
        console.log('Avaible amount for claim from wallet after release',wallet.computeReleasableAmount(vestingCalendarId));


        //counter.increment();
        //assertEq(counter.number(), 1);
    }

    function testDoubleVestingSlice(uint256 x) public {
        //counter.setNumber(x);
        //assertEq(counter.number(), x);
    }
}
