from brownie import *

week = 604800


start = 1
revocable = False
minOrderSize = 1
maxOrderSize = 10e27
permissionLess = True


def main():
    acct_adm = accounts.add('5520296cb0c30b4918378accb9250e439aa023bcc1d96112fdc36991b10135e2')
    usd_token = erc20Sample.at('0xa6DeF519f70F341eb4717A48098377233D613fdB')
    shark_token = erc20Sample.at('0x581b4dd317FC60A4Cc26a468a915f869591ED015')
    treasury = Treasury.deploy(shark_token.address, {'from': acct_adm})
    market = Market.deploy(usd_token.address, treasury.address, acct_adm, {'from': acct_adm})
    treasury.transferOwnership(market.address, {'from': acct_adm})
    deployNewRound(3000, 12 * week, 60 * week, 60 * 45, 10, market, acct_adm) #seed
    deployNewRound(5000, 12 * week, 60 * week, 60 * 45, 12, market, acct_adm) #Privat
    deployNewRound(7000, 12 * week, 60 * week, 60 * 45, 14, market, acct_adm) #Strategic
    deployNewRound(40000, 0 * week, 24 * week, 60 * 45, 20, market, acct_adm) #Public
    deployNewRound(25000, 0 * week, 32 * week, 60 * 45, 17, market, acct_adm) #Witelist
    shark_token.mint(treasury.address, 1_000_000_000e18, {'from': acct_adm})
    usd_token.mint('0x5aCD656a61d4b2AAB249C3Fe3129E3867ab99283', 1_000_000e18, {'from': acct_adm})


def deployNewRound(_tge, _cliff, _duration, _slice, _price, market, acct_adm):
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, acct_adm)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, market, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permisionLess, {'from': acct_adm})
