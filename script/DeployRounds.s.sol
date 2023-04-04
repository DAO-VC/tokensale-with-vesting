// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/interfaces/IMarket.sol";

contract DeployRoundsScript is Script {
    // GOERLI ONLY
    //IERC20 private constant usdc = IERC20(USDC);
    IMarket private constant market = IMarket(0x71d3b4779Fe591147db2013359A7B1A568535812); //USD with unlimit mint
    IMarket.MarketInfo public marketMasterData;

    function setUp() public {
        //marketMasterData.tgeRatio = 3000; // 3.000 %
        marketMasterData.start = block.timestamp;  // start imediatly
        //marketMasterData.cliff = 12 weeks; // 3 monthes
        //marketMasterData.duration = 60 weeks; // 12 monthes
        //marketMasterData.slicePeriod = 4 weeks; // 1 month
        marketMasterData.revocable = false;
        //marketMasterData.price = 10; // price = price*1000, thats means price = 1 eq price = 0.1 
        marketMasterData.minOrderSize = 1; // min order 1 token
        marketMasterData.maxOrderSize = 10e10; // max order // unlim 
        marketMasterData.permisionLess = true; // without whitelist

    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // tge, cliff, duration, slice, price
        //deployNewRound(3000, 12 weeks, 60 weeks, 4 weeks, 10); //Seed
        deployNewRound(5000, 12 weeks, 60 weeks, 4 weeks, 12); //Private
        deployNewRound(7000, 12 weeks, 60 weeks, 4 weeks, 14); //Strategic
        deployNewRound(40000, 0 weeks, 24 weeks, 4 weeks, 20); //Public
        deployNewRound(25000, 0 weeks, 32 weeks, 4 weeks, 17); //Whitelist

        vm.stopBroadcast();
    }

    function deployRound(IMarket.MarketInfo memory _data) public {
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
