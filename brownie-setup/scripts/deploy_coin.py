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
    acct_adm = accounts.add('39adf369c95a229e70db7dd596aaff6447ef5da9543d4a170cdb128376f0b036')

    shark_token = Coin.deploy("SharkCoin", "SHRK", 1e27, acct_adm, {'from': acct_adm, "gas_limit": 10000000}, publish_source=True)
    #testnet!!! 
    shark_token  = Coin.at('0x756c1A6135786A86dBdcee4897256992180675b2')
    #   Coin deployed at: 0x756c1A6135786A86dBdcee4897256992180675b2 (testnet)
    #   Coin deployed at: 0x756c1A6135786A86dBdcee4897256992180675b2 (mainnet)