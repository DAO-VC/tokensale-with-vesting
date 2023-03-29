// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Treasury.sol";
import "../src/Market.sol";

contract DeployScript is Script {
    address constant CurrencyToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant ProductToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    Treasury public treasury;
    Market public market;

    function setUp() public {}

    function deployMarketAndTreasury() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        // deploy tresary and market
        treasury = new Treasury(ProductToken);
        market = new Market(CurrencyToken, address(treasury));

        vm.stopBroadcast();
    }

    function setWhiteList() public {

    }

    function setTeamVestingCalendar() public {

    }

    function setPrivateRound() public {

    }

    function setPublicRound() public {

    }

    function setSeedRound() public {

    }
}
// https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/16-foundry-deployment/
// forge script script/Deploy.s.sol:DeployScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
