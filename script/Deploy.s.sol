// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Treasury.sol";
import "../src/Market.sol";

contract DeployScript is Script {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant SharkToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    //uint256 constant tokenCap = 


    function setUp() public {}

    function run() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        // deploy tresary and market
        Treasury tresary = new Treasury(SharkToken);
        Market market = new Market(USDC, address(tresary));

        vm.stopBroadcast();
    }
}
// https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/16-foundry-deployment/
// forge script script/Deploy.s.sol:DeployScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
