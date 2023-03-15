// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VestingWallet.sol";

contract VestingWalletTest is Test {
    VestingWallet public wallet;
    // dev: any erc20 token for testing vesting calendar on mainnet forking
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F;//
    //address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC_WHALE = 0x3C7739f71c4Fa409De4e732d7a2fDc95b74c4581;
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

        uint256 start = 1622551248; // Tuesday, 1 June 2021 г., 12:40:48 https://www.epochconverter.com/
        uint256 cliff = 0;
        uint256 duration = 604800; // seconds in week
        uint256 slicePeriodSeconds = 1;
        bool revocable = true;
        uint256 amount = 100 * 1e6; 

        // uint256 calendarNumber = 1;

        wallet.createVestingSchedule(address(this), start, cliff, duration, slicePeriodSeconds, revocable, amount);

        console.log('Total vestings calendars', wallet.getVestingSchedulesCount());

        uint256 vestingScheduleCount = wallet.getVestingSchedulesCountByBeneficiary(address(this));
        console.log('Total vestings calendars for current user', vestingScheduleCount);

        
        
        //bytes32 vestingCalendarId = wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber);

        //console.log('Vesting callendar index', wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber));

        //console.log('Avaible amount for claim from wallet',wallet.computeReleasableAmount(wallet.computeVestingScheduleIdForAddressAndIndex(address(this), wallet.getVestingSchedulesCountByBeneficiary(address(this)))));

        
        //wallet.release(wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber), wallet.computeReleasableAmount(wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber)));

        //console.log('balance of test user after release tokens',usdc.balanceOf(address(this)));

        //console.log('Avaible amount for claim from wallet',wallet.computeReleasableAmount(wallet.computeVestingScheduleIdForAddressAndIndex(address(this), calendarNumber)));


        //counter.increment();
        //assertEq(counter.number(), 1);
    }

    function testDoubleVestingSlice(uint256 x) public {
        //counter.setNumber(x);
        //assertEq(counter.number(), x);
    }
}
