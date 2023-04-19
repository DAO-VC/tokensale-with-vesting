from brownie import *

week = 604800


start = 1681807247
revocable = False
minOrderSize = 1
maxOrderSize = 10e27
permissionLess = True


def main():
    acct_adm = accounts.add('5520296cb0c30b4918378accb9250e439aa023bcc1d96112fdc36991b10135e2')
    usd_token = erc20Sample.at('0xf98cBAcf55e554ef225E7f4251001c2DFEED33Aa')#deploy("USD", "USD", {'from': acct_adm})
    shark_token = erc20Sample.at('0xB0A1Afed4029540B9D5df9e9eC32B37EeFE864eE')#deploy("Shark", "SHR", {'from': acct_adm})
    treasury = Treasury.deploy(shark_token.address, {'from': acct_adm})
    market = Market.deploy(usd_token.address, treasury.address, acct_adm, {'from': acct_adm})
    treasury.transferOwnership(market.address, {'from': acct_adm})
    #deployNewRound(_tge=3000, _cliff=12 * week, _duration=60 * week, _slice=60 * 10, _price=10, market=market, acct_adm=acct_adm, isInternal=False) #seed
    deployNewRound(0, 0, 60 * 5 * 20, 60 * 5, 12, market, acct_adm, isInternal=False)  # Private
    # deployNewRound(7000, 12 * week, 60 * week, 60 * 10, 14, market, acct_adm, isInternal=False) #Strategic
    # deployNewRound(40000, 0 * week, 24 * week, 60 * 10, 20, market, acct_adm, isInternal=False) #Public
    deployNewRound(25000, 0 * week, 60 * 5 * 20, 60 * 5, 17, market, acct_adm, permissionLess=False, isInternal=False) #Witelist
    deployNewRound(27000, 0 * week, 60 * 5 * 20, 60 * 5, 1e27, market, acct_adm, isInternal=False)  # Liquidity
    # deployNewRound(33000, 0 weeks, 8 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Giveaways
    # deployNewRound(8300, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Rewards
    # deployNewRound(5000, 0 weeks, 44 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Marketing
    # deployNewRound(0, 44 weeks, 132 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Advisors
    # deployNewRound(5000, 0 weeks, 64 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Ecosystem & Partnership
    # deployNewRound(0, 48 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // Core Team
    # deployNewRound(0, 16 weeks, 144 weeks, 4 weeks, 1e27, market, acct_adm, isInternal=False); // P2E In game liquidity

    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992')
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283')
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', '0x1892de64127590BF0a8a0B989ff342681286143B')
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xfb592B5947798B1cfcDaD72619a8e6eE98924992')
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283')
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0xB09ecEe4335B97CbE76521c317081Bccf83d6190')
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', '0x1892de64127590BF0a8a0B989ff342681286143B')
    shark_token.mint(treasury.address, 1_000_000_000e18, {'from': acct_adm})
    usd_token.mint('0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', 1_000_000e18, {'from': acct_adm})


def deployNewRound(_tge, _cliff, _duration, _slice, _price, market, acct_adm, start=1681807247, minOrderSize=1e18, maxOrderSize=10_000e18, revocable=False, permissionLess=True, isInternal=True):
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, isInternal, acct_adm)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, market, isInternal, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, isInternal, {'from': acct_adm})


