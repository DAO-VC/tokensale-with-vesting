#!/usr/bin/python3
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


def main():
    # account = get_account()
    # print(f"Deploying to {network.show_active()}")
    # market = Market.deploy(usd_token.address, treasury.address, acct_adm, {'from': acct_adm})
    #     {"from":  acct_adm},
    #     publish_source=config["networks"][network.show_active()]["verify"],
    # )
    # Optional, deploy the ProxyAdmin and use that as the admin contract
    
    acct_adm = accounts[0] #.add('5520296cb0c30b4918378accb9250e439aa023bcc1d96112fdc36991b10135e2')
    #
    usd_token = erc20Sample.deploy("USD", "USD", {'from': acct_adm}) #at('0xf98cBAcf55e554ef225E7f4251001c2DFEED33Aa')
    print(accounts[0], "deploying shark_token:")
    shark_token = Coin.deploy("Shark", "SHR", 1e27, acct_adm, {'from': acct_adm, "gas_limit": 10000000})
     
    # #Coin.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    # print(" deploying proxy_admin_coin:")
    # proxy_admin_coin = ProxyAdmin.deploy(
    #     {"from":  acct_adm},
    # )

    # coin_encoded_initializer_function = encode_function_data() #"Shark", "SHR", 1e9*1e18, acct_adm)
    # # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    # print(" deploying proxy_coin:")    
    # proxy_coin = TransparentUpgradeableProxy.deploy(
    #     shark_token.address,
    #     proxy_admin_coin.address,
    #     coin_encoded_initializer_function,}
    #     {"from": acct_adm}, # "gas_limit": 1000000
    # )
    
    # # print (proxy_coin.error(), proxy_coin.traceback() )

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

    
    print(accounts[0], "deploying market:")
    market_logic = Market.deploy({'from': acct_adm, "gas_limit": 10000000})
    
     
    #Coin.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    print(" deploying proxy_admin_market:")
    proxy_admin_market = ProxyAdmin.deploy(
        {"from":  acct_adm},
    )

    encoded_initializer_function_market= encode_function_data(market_logic.initialize,usd_token.address, proxy_treas.address, shark_token.address) #"Shark", "SHR", 1e9*1e18, acct_adm)
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    print(" deploying proxy_market:")    
    market= TransparentUpgradeableProxy.deploy(
        market_logic.address,
        proxy_admin_market.address,
        encoded_initializer_function_treas,
        {"from": acct_adm}, # "gas_limit": 1000000
    )
    