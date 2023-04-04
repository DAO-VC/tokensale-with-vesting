// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Market.sol";
import "../src/Treasury.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MarketTest is Test {
    Treasury public productTreasury;
    Market public market;
    // dev: any erc20 token for testing vesting calendar on mainnet forking
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F;//
    // dev: quote asset for testing tokensale on mainnet is WETH
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC_WHALE = 0x756D64Dc5eDb56740fC617628dC832DDBCfd373c; // binance account with 3 billions USDC
    IERC20 private constant usdc = IERC20(USDC);
    IERC20 public productToken; // will deploy in setUP
    uint256 private constant productTokenCap = 10e6 * 10e18;
    Market.MarketInfo public marketMasterData;


    function setUp() public {
        // ---- INIT Contracts (product, currency, treasury, market) ----
        // currency
        vm.startPrank(USDC_WHALE);
        usdc.transfer(address(this), 5000 * 10e6);
        vm.stopPrank();
        // product
        productToken = new ProductToken(productTokenCap);
        // treasury
        productTreasury = new Treasury(address(productToken));
        console.log("Treasury init ok", address(productTreasury));
        productToken.transfer(address(productTreasury), productTokenCap);
        console.log("Treasury balance of product token", productToken.balanceOf(address(productTreasury)));
        // market
        market = new Market(address(usdc), address(productTreasury), address(this));
        productTreasury.transferOwnership(address(market));
        console.log("Market init ok", address(market));

    }

    function testSaleAndVesting() public {
        // set-up vesting template in market contract


        marketMasterData.tgeRatio = 3000; // 10.000 %
        marketMasterData.start = block.timestamp;
        marketMasterData.cliff = 12 weeks;
        marketMasterData.duration = 60 weeks;
        marketMasterData.slicePeriod = 4 weeks;
        marketMasterData.revocable = false;
        marketMasterData.price = 10; // price = price*1000, thats means price = 1 eq price = 0.001 
        marketMasterData.minOrderSize = 1; // min order 1 token
        marketMasterData.maxOrderSize = 10e10; // max order 10k tokens
        marketMasterData.permisionLess = true; // without whitelist

        deployMarket(marketMasterData);
        console.log("New market deployed");
        console.log("User balance of product token before buying 10k tokens", productToken.balanceOf(address(this)));
        buyAtMarket(0, 10e3); // marketId, tokens to buy
        //console.log("Bu");
        console.log("Timestamp:", block.timestamp);
        console.log("Order price", market.calculateOrderPrice(0, 10e3));
        console.log("Slice period", marketMasterData.slicePeriod);

        // check vesting calendar for N periods
        //for (uint256 index = 0; index < ((marketMasterData.duration - marketMasterData.cliff) / marketMasterData.slicePeriod); index++) {
            //checkVesting(0, block.timestamp + ((index + 1)* marketMasterData.slicePeriod));
        //}
        console.log("User balance of product token before vesting", productToken.balanceOf(address(this)));
        checkVesting(0, marketMasterData.start + marketMasterData.cliff);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 1 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 2 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 3 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 4 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 5 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 6 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 7 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 8 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 9 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 10 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 11 * marketMasterData.slicePeriod);
        checkVesting(0, marketMasterData.start + marketMasterData.cliff + 12 * marketMasterData.slicePeriod);


        console.log("User balance of product token after vesting", productToken.balanceOf(address(this)));


    }
/*
    function testTeamVesting() public {

        // deployMarkets 
        // migrateUser
        // checkVestingCalendar

    }

    function testWhiteListSale() public {

        // deployMarket
        // addWhitelist
        // buy
        // checkVesting

    }
*/
    function deployMarket(Market.MarketInfo memory _data) public {
                market.deployMarket(    _data.price,
                                        _data.minOrderSize,
                                        _data.maxOrderSize,
                                        _data.tgeRatio,
                                        _data.start,
                                        _data.cliff,
                                        _data.duration,
                                        _data.slicePeriod,
                                        _data.revocable,
                                        _data.permisionLess 
                                        );
    }

    function checkVesting(uint256 _market, uint256 _timestamp) public {
            vm.warp(_timestamp);
            console.log("Timestamp:", block.timestamp);
            ITreasury.VestingSchedule memory userInfoForRound = market.getVestingScheduleForIndex(_market, address(this));
            //bytes32 vestingCalendarId = productTreasury.computeVestingScheduleIdForAddressAndIndex(address(this), 0);
            //uint256 avaibleToClaim = productTreasury.computeReleasableAmount(vestingCalendarId);
            console.log("Alredy claimed:", userInfoForRound.released);
            console.log("Avaible to claim", market.avaibleToClaim(_market, address(this)));
            market.claimForIndex(_market);
            //console.log("Treasury balance of product token", productToken.balanceOf(address(productTreasury)));
            //market.claimForAdress(address(this));
            
    }

    function buyAtMarket(uint256 _market, uint256 _amount) public {
        // buy tokens from market contract
        //buy(uint256 _market, uint256 _amount, address _benefeciary) 
        console.log("Price for 10k tokens", market.calculateOrderPrice(_market, _amount));
        usdc.approve(address(market), market.calculateOrderPrice(_market, _amount));
        market.buy(0, _amount, address(this));
        // check tge tokens
        console.log(productToken.balanceOf(address(this)));
    }

}

contract ProductToken is ERC20 {
    constructor(uint256 _cap) ERC20("Product", "PTK") {
        _mint(msg.sender, _cap);
    }
}