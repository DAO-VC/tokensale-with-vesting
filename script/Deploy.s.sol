// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Treasury.sol";
import "../src/Market.sol";

contract DeployScript is Script {
    // GOERLI ONLY
    //address constant CurrencyToken = 0x37bEe9DAeCb30cd44305FF76FcDD44E471244eFa; //USD with unlimit mint
    //address constant ProductToken = 0x7b8d1D0CA2d679ca8ffd37491C90b066d4511c12; //SHARK with unlimit mint
    //address constant CurrencyTreasury = 0x9df1958eF717F27cE03719341dCBCf049da190B5; // My MM

    // Binance Testnet

    
    address constant CurrencyToken = 0xBBf54eD533d1df95C201d0AFd859C1707F7857aB; //USD with unlimit mint
    address constant ProductToken = 0x4fBd6fbd58045113BA7aDf02034e0FcaA3e85396; //SHARK with unlimit mint
    address constant CurrencyTreasury = 0x9df1958eF717F27cE03719341dCBCf049da190B5; // My MM


    //address constant ProductTreasury = 0xea0EcD6659BF79F6517602813346Cb1be80053AC;

    //ITreasury public treasury = ITreasury(ProductTreasury);
    Treasury public treasury;
    Market public market;
    Market.MarketInfo public marketMasterData;

    function setUp() public {
        marketMasterData.tgeRatio = 3000; // 3.000 %
        marketMasterData.start = block.timestamp;  // start imediatly
        marketMasterData.cliff = 12 weeks; // 3 monthes
        marketMasterData.duration = 60 weeks; // 12 monthes
        marketMasterData.slicePeriod = 4 weeks; // 1 month
        marketMasterData.revocable = false;
        marketMasterData.price = 10; // price = price*1000, thats means price = 1 eq price = 0.1 
        marketMasterData.minOrderSize = 1; // min order 1 token
        marketMasterData.maxOrderSize = 10e10; // max order // unlim 
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
        //deployMarket(marketMasterData);
        // tge, cliff, duration, slice, price
        //deployNewRound(3000, 12 weeks, 60 weeks, 4 weeks, 10); //Seed for prod
        deployNewRound(3000, 12 minutes, 60 minutes, 4 minutes, 10); //Seed for front test
        deployNewRound(5000, 12 weeks, 60 weeks, 4 weeks, 12); //Private
        deployNewRound(7000, 12 weeks, 60 weeks, 4 weeks, 14); //Strategic
        deployNewRound(40000, 0 weeks, 24 weeks, 4 weeks, 20); //Public
        deployNewRound(25000, 0 weeks, 32 weeks, 4 weeks, 17); //Whitelist

        vm.stopBroadcast();
    }

    function deployRound(Market.MarketInfo memory _data) public {
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

    function deployNewRound(uint256 _tge, uint256 _cliff, uint256 _duration, uint256 _slice, uint256 _price) public {
        marketMasterData.tgeRatio = _tge; 
        marketMasterData.cliff = _cliff; 
        marketMasterData.duration = _duration; 
        marketMasterData.slicePeriod = _slice; 
        marketMasterData.price = _price; 
        deployRound(marketMasterData);

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
