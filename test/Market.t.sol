// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Market.sol";

contract MarketTest is Test {
    Market public market;
    // dev: any erc20 token for testing vesting calendar on mainnet forking
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // DAI 0x6B175474E89094C44Da98b954EedeAC495271d0F;//
    // dev: quote asset for testing tokensale on mainnet is WETH
    //address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant USDC_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // binance account with 3 billions USDC
    IERC20 private constant usdc = IERC20(USDC);

    function setUp() public {
    }

    function testSaleAndVesting() public {

    }

}