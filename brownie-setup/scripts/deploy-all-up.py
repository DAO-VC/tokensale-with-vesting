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
import datetime
import math

week = 604800
month_sec = 60*5 # 5 min - test # 365.25* 24*60*60 / 12
start =  datetime.datetime.now ()#1681806409
                                #1682161043.541216
start = math.floor(start.timestamp())
print (start)
revocable = False
minOrderSize = 1
maxOrderSize = 10e27
permissionLess = True
denominator = 1000


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
    treasury_proxy = TransparentUpgradeableProxy.deploy(
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

    encoded_initializer_function_market= encode_function_data(market_logic.initialize,shark_token.address, treasury_proxy.address, acct_adm.address) #"Shark", "SHR", 1e9*1e18, acct_adm)
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    print(" deploying proxy_market:")    

    market_proxy= TransparentUpgradeableProxy.deploy(
            market_logic.address,
            proxy_admin_market.address,
            encoded_initializer_function_market,
            {"from": acct_adm}, # "gas_limit": 1000000
        )
    
    treasury = Contract.from_abi("Treasury", treasury_proxy.address, treasury_logic.abi)
    treasury.transferOwnership(market_proxy.address, {'from': acct_adm})
    market = Contract.from_abi("Market", market_proxy.address, market_logic.abi)
    
    
    # deployNewRound(0, 0, 60 * 5 * 20, 60 * 5, 12, market, acct_adm) #Privat
    # deployNewRound(7000, 12 * week, 60 * week, 60 * 10, 14, market, acct_adm) #Strategic
    # deployNewRound(40000, 0 * week, 24 * week, 60 * 10, 20, market, acct_adm) #Public
    # deployNewRound(25000, 0 * week, 32 * week, 60 * 10, 17, market, acct_adm) #Witelist
    shark_token.transfer(treasury.address, 1_000_000_000e18, {'from': acct_adm})
    usd_token.mint('0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', 1_000_000e18, {'from': acct_adm})
#                 (_tge,        _cliff,     _duration,   _slice,  _price, market, acct_adm, start=1681807247, minOrderSize=1e18, maxOrderSize=10_000e18, revocable=False, permissionLess=True, isInternal=True):    
    deployNewRound(30,  month_sec * 3, month_sec * 12, month_sec,     10, market, acct_adm,  isInternal=True) #seed
    deployNewRound(50,  month_sec * 3, month_sec * 12, month_sec,     12, market, acct_adm, isInternal=True)  # Private
    deployNewRound(70,  month_sec * 3, month_sec * 12, month_sec,     14, market, acct_adm, isInternal=True) #Strategic
    deployNewRound(400,             0, month_sec * 6,  month_sec,     20, market, acct_adm, isInternal=False) #Public
    deployNewRound(250,             0, month_sec * 8,  month_sec,     17, market, acct_adm, permissionLess=False, isInternal=False) #Witelist
    # deployNewRound(27000, 0 * week, 60 * 5 * 20, 60 * 5, 1e27, market, acct_adm, isInternal=False)  # Liquidity
    # deployNewRound(33000, 0 weeks, 8 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Giveaways
    # deployNewRound(8300, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Rewards
    # deployNewRound(5000, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Marketing
    # deployNewRound(0, 44 weeks, 132 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Advisors
    # deployNewRound(5000, 0 weeks, 64 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Ecosystem & Partnership
    # deployNewRound(0, 48 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Core Team
    # deployNewRound(0, 16 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // P2E In game liquidity

    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992', {'from': acct_adm})
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', {'from': acct_adm})
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190', {'from': acct_adm})
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x1892de64127590BF0a8a0B989ff342681286143B', {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992', {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190', {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x1892de64127590BF0a8a0B989ff342681286143B', {'from': acct_adm})

def deployNewRound(_tge, _cliff, _duration, _slice, _price, market, acct_adm, start = start, minOrderSize=1e18, maxOrderSize=10_000e18, revocable=False, permissionLess=True, isInternal=True):
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, isInternal, acct_adm)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, market, isInternal, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, isInternal,  denominator, {'from': acct_adm})


# Stan Takt, [22.04.2023 15:03]
# Coin deployed at:

# Stan Takt, [22.04.2023 15:03]
# 0xd3733C396c4A189D82c5C11CE2ad95fBa9456103

# Stan Takt, [22.04.2023 15:04]
# market
# Stan Takt, [22.04.2023 15:04]
# 0x0eFa44563212d8a98CB8621a3Fad6aBBdb629376

# erc20Sample deployed at: 0x5889F4dB9417782FE3632D1fd4aE5DA26F56329a