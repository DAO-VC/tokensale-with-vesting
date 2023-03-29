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

    function setUp() public {}

    function deployContracts() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        // deploy tresary and market
        treasury = new Treasury(ProductToken);
        market = new Market(CurrencyToken, address(treasury), CurrencyTreasury);

        vm.stopBroadcast();
    }

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
}
// https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/16-foundry-deployment/
// forge script script/Deploy.s.sol:DeployScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
