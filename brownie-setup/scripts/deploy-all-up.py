# from brownie import *
from brownie import (
    Market,
    Treasury,
    TransparentUpgradeableProxy,
    ProxyAdmin,
    erc20Sample,
    Coin,
    config,
    network,
    Contract,
    accounts
)
from scripts.helpful_scripts import get_account, encode_function_data


week = 604800


start = 1681806409
revocable = False
minOrderSize = 1
maxOrderSize = 10e27
permissionLess = True


def main():
    acct_adm = accounts.add('5520296cb0c30b4918378accb9250e439aa023bcc1d96112fdc36991b10135e2')
    usd_token = erc20Sample.deploy("USD", "USD", {'from': acct_adm})
    #erc20Sample.at('0xf98cBAcf55e554ef225E7f4251001c2DFEED33Aa')
    # shark_token = erc20Sample.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    shark_token = Coin.deploy("Shark", "SHR", 1e27, acct_adm, {'from': acct_adm, "gas_limit": 10000000})

    # treasury = Treasury.deploy(shark_token.address, {'from': acct_adm})    
    # market = Market.deploy(usd_token.address, treasury.address, acct_adm, {'from': acct_adm})
    
    
    print(accounts[0], "deploying treasury:")
    treasury_logic = Treasury.deploy({'from': acct_adm, "gas_limit": 10000000})
    
     
    #Coin.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    print(" deploying proxy_admin_treasury:")
    proxy_admin_treas = ProxyAdmin.deploy(
        {"from":  acct_adm},
    )

    encoded_initializer_function_treas = encode_function_data(treasury_logic.initialize, shark_token) #"Shark", "SHR", 1e9*1e18, acct_adm)
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    print(" deploying proxy_treasury:")    
    treasury = TransparentUpgradeableProxy.deploy(
        treasury_logic.address,
        proxy_admin_treas.address,
        encoded_initializer_function_treas,
        {"from": acct_adm}, # "gas_limit": 1000000
    )
    
    # print (proxy_coin.error(), proxy_coin.traceback() )

    
    print(accounts[0], "deploying market_logic:")
    market_logic = Market.deploy({'from': acct_adm, "gas_limit": 10000000})
    
     
    #Coin.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    print(" deploying proxy_admin_market:")
    proxy_admin_market = ProxyAdmin.deploy(
        {"from":  acct_adm},
    )

    encoded_initializer_function_market= encode_function_data(market_logic.initialize,shark_token.address, treasury.address, acct_adm.address) #"Shark", "SHR", 1e9*1e18, acct_adm)
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    print(" deploying proxy_market:")    

    market= TransparentUpgradeableProxy.deploy(
            market_logic.address,
            proxy_admin_market.address,
            encoded_initializer_function_market,
            {"from": acct_adm}, # "gas_limit": 1000000
        )
    
    treasuryP = Contract.from_abi("Treasury", treasury.address, treasury_logic.abi)
    treasuryP.transferOwnership(market.address, {'from': acct_adm})
    marketP = Contract.from_abi("Market", market.address, market_logic.abi)
    deployNewRound(3000, 12 * week, 60 * week, 60 * 10, 10, marketP, acct_adm) #seed
    deployNewRound(0, 0, 60 * 5 * 20, 60 * 5, 12, marketP, acct_adm) #Privat
    deployNewRound(7000, 12 * week, 60 * week, 60 * 10, 14, marketP, acct_adm) #Strategic
    deployNewRound(40000, 0 * week, 24 * week, 60 * 10, 20, marketP, acct_adm) #Public
    deployNewRound(25000, 0 * week, 32 * week, 60 * 10, 17, marketP, acct_adm) #Witelist
    shark_token.transfer(treasury.address, 1_000_000_000e18, {'from': acct_adm})
    usd_token.mint('0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', 1_000_000e18, {'from': acct_adm})


def deployNewRound(_tge, _cliff, _duration, _slice, _price, market, acct_adm):
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, acct_adm)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, market, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, False, {'from': acct_adm})
