from brownie import *
from datetime import datetime, timezone
import math


# start = 1681807247
revocable = False
permissionLess = True
beneficiary = "0x34B54EBC6c5B99FE435252d2fcf75E0f3167DE1D"
minOrderSize=1e18 / 0.02
maxOrderSize=10_000e18 / 0.02
 
week = 604800
month_sec =  365.25* 24*60*60 / 12
start =  datetime.strptime('05/05/23 17:00:00+0000','%d/%m/%y %H:%M:%S%z')

#1682161043.541216
start = math.floor(start.timestamp())
print (start)

def main():
    acct_adm = accounts.add('')
    usd_token = erc20Sample.at('0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56')# BUSD  main
    # usd_token = erc20Sample.at('0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee')# BUSD  test
    
    # usd_token = erc20Sample.at('0xaf9Cc07EC5b4Ed31EED3E2Ba1157AC99e06aA432')# USDT binance  test
    shark_token = erc20Sample.at('0x756c1A6135786A86dBdcee4897256992180675b2')     
    # shark_token = Coin.deploy("Shark", "SHR", 1e27, acct_adm,  {'from': acct_adm})
    
    treasury = Treasury.deploy(shark_token.address, {'from': acct_adm})
    
    market = Market.deploy(usd_token.address, treasury.address, beneficiary, {'from': acct_adm})
    
    # treasury = Treasury.at("0xFBF47560C0A52fBA6164429DB12938B7a07D0330") # testnet bnb
    
    # market = Market.at('0xaae4cDbd86725A9947eBbF39eE213c949E8a827B') # testnet bnb
    
    treasury.transferOwnership(market.address, {'from': acct_adm})

    deployNewRound(30000,  month_sec * 3, month_sec * 12, month_sec,     10, market, acct_adm,  isInternal=True) #seed
    deployNewRound(50000,  month_sec * 3, month_sec * 12, month_sec,     12, market, acct_adm, isInternal=True)  # Private
    deployNewRound(70000,  month_sec * 3, month_sec * 12, month_sec,     14, market, acct_adm, isInternal=True) #Strategic
    deployNewRound(400000, 0, month_sec * 3,  month_sec,     20, market, acct_adm, isInternal=False) #Public
    deployNewRound(400000, 0, month_sec * 3,  month_sec,     17, market, acct_adm, permissionLess=False, isInternal=False) #Witelist
    #deployNewRound(_tge=3000, _cliff=12 * week, _duration=60 * week, _slice=60 * 10, _price=10, market=market, acct_adm=acct_adm, isInternal=False) #seed
    # deployNewRound(0, 0, 60 * 5 * 20, 60 * 5, 12, market, acct_adm, isInternal=False)  # Private
    # deployNewRound(7000, 12 * week, 60 * week, 60 * 10, 14, market, acct_adm, isInternal=False) #Strategic
    # deployNewRound(40000, 0 * week, 24 * week, 60 * 10, 20, market, acct_adm, isInternal=False) #Public
    # deployNewRound(25000, 0 * week, 60 * 5 * 20, 60 * 5, 17, market, acct_adm, permissionLess=False, isInternal=False) #Witelist
    # deployNewRound(27000, 0 * week, 60 * 5 * 20, 60 * 5, 1e27, market, acct_adm, isInternal=False)  # Liquidity

    # deployNewRound(33000, 0 weeks, 8 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Giveaways
    # deployNewRound(8300, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Rewards
    # deployNewRound(5000, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Marketing
    # deployNewRound(0, 44 weeks, 132 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Advisors
    # deployNewRound(5000, 0 weeks, 64 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Ecosystem & Partnership
    # deployNewRound(0, 48 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Core Team
    # deployNewRound(0, 16 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // P2E In game liquidity
    shark_token.transfer(treasury.address, 8_000_000e18, {'from': acct_adm})
    # usd_token.mint('0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', 1_000_000e18, {'from': acct_adm})
    # usd_token.mint('0xfb592B5947798B1cfcDaD72619a8e6eE98924992', 1_000_000e18, {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x34B54EBC6c5B99FE435252d2fcf75E0f3167DE1D', {'from': acct_adm})
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x34B54EBC6c5B99FE435252d2fcf75E0f3167DE1D',{'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x1CC3d84Fd607eD11c7966CF89fc6189958c996DD', {'from': acct_adm})
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x1CC3d84Fd607eD11c7966CF89fc6189958c996DD',{'from': acct_adm})
    
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x98C16C06B8da1262a5063195b3a61b7Fdd18d7b2', {'from': acct_adm})
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x98C16C06B8da1262a5063195b3a61b7Fdd18d7b2',{'from': acct_adm})    
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x176dfd40d92c6d592fc5be3a35856ec64737ffce')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x176dfd40d92c6d592fc5be3a35856ec64737ffce')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xe142612183378531C1ad8dB131C9808F0a848bCf')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xe142612183378531C1ad8dB131C9808F0a848bCf')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x1892de64127590BF0a8a0B989ff342681286143B')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x1892de64127590BF0a8a0B989ff342681286143B')
    # market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    # market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')

def deployNewRound(_tge, _cliff, _duration, _slice, _price, market, acct_adm, start=start, minOrderSize=minOrderSize, maxOrderSize=maxOrderSize, revocable=False, permissionLess=True, isInternal=True):

    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, isInternal, acct_adm)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, market, isInternal, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, isInternal, {'from': acct_adm})


