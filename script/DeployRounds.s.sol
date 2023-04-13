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
        marketMasterData.start = block.timestamp;  // start imediatly
        marketMasterData.revocable = false;
        marketMasterData.minOrderSize = 1; // min order 1 token
        marketMasterData.maxOrderSize = 10e10; // max order // unlim 
        marketMasterData.permisionLess = true; // without whitelist

    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // tge, cliff, duration, slice, price
        deployNewRound(3000, 12 weeks, 60 weeks, 4 weeks, 10); //Seed
        deployNewRound(5000, 12 weeks, 60 weeks, 4 weeks, 12); //Private
        deployNewRound(7000, 12 weeks, 60 weeks, 4 weeks, 14); //Strategic
        deployNewRound(40000, 0 weeks, 24 weeks, 4 weeks, 20); //Public
        deployNewRound(25000, 0 weeks, 32 weeks, 4 weeks, 17); //Whitelist

        deployNewRound(27000, 0 weeks, 32 weeks, 4 weeks, type(uint256).max); //Liquidity
        deployNewRound(33000, 0 weeks, 8 weeks, 4 weeks, type(uint256).max); //Giveaways
        deployNewRound(8300, 0 weeks, 44 weeks, 4 weeks, type(uint256).max); //Rewards
        deployNewRound(5000, 0 weeks, 44 weeks, 4 weeks, type(uint256).max); //Marketing
        deployNewRound(0, 44 weeks, 132 weeks, 4 weeks, type(uint256).max); //Advisors
        deployNewRound(5000, 0 weeks, 64 weeks, 4 weeks, type(uint256).max); //Ecosystem & Partnership	
        deployNewRound(0, 48 weeks, 144 weeks, 4 weeks, type(uint256).max); //Core Team	
        deployNewRound(0, 16 weeks, 144 weeks, 4 weeks, type(uint256).max); //P2E In game liquidity	
        


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
