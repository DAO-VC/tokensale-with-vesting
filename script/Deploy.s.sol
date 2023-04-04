// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Treasury.sol";
import "../src/Market.sol";

contract DeployScript is Script {
    // GOERLI ONLY
    address constant CurrencyToken = 0x37bEe9DAeCb30cd44305FF76FcDD44E471244eFa; //USD with unlimit mint
    address constant ProductToken = 0x7b8d1D0CA2d679ca8ffd37491C90b066d4511c12; //SHARK with unlimit mint
    address constant CurrencyTreasury = 0x9df1958eF717F27cE03719341dCBCf049da190B5; // My MM
    Treasury public treasury;
    Market public market;
    Market.MarketInfo public marketMasterData;

    function setUp() public {
        marketMasterData.tgeRatio = 3000; // 3.000 %
        marketMasterData.start = block.timestamp;
        marketMasterData.cliff = 12 weeks; // 3 monthes
        marketMasterData.duration = 48 weeks; // 12 monthes
        marketMasterData.slicePeriod = 4 weeks; // 1 month
        marketMasterData.revocable = false;
        marketMasterData.price = 10; // price = price*1000, thats means price = 1 eq price = 0.001 
        marketMasterData.minOrderSize = 1; // min order 1 token
        marketMasterData.maxOrderSize = 10e10; // max order 10k tokens
        marketMasterData.permisionLess = true; // without whitelist

    }

    function run() public {
        //string memory seedPhrase = vm.readFile(".secret");
        //uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // deploy tresary and market
        treasury = new Treasury(ProductToken);
        market = new Market(CurrencyToken, address(treasury), CurrencyTreasury);
        treasury.transferOwnership(address(market));
        deployMarket(marketMasterData);

        vm.stopBroadcast();
    }

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

/*
    function deployWhiteList() public {

    }

    function deployTeamVestingCalendar() public {

    }

    function deployPrivateRound() public {

    }

    function deployPublicRound() public {

    }

    function deploySeedRound() public {

    }
    */
}
// https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/16-foundry-deployment/
// forge script script/Deploy.s.sol:DeployScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
