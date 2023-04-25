from brownie import *

user_batch = 5

def main():
    acct_adm = accounts.add('5520296cb0c30b4918378accb9250e439aa023bcc1d96112fdc36991b10135e2')
    migrator = Migrator.deploy('0x8dad480CE992c6FC58b9d212A14Bd60693e77a9e', {'from': acct_adm})
    market = Market.at('0x8dad480CE992c6FC58b9d212A14Bd60693e77a9e')
    markets = []
    addresses_2 = []
    amounts = []

    for i in range(user_batch):
        account = accounts.add()
        markets.append(4)
        addresses_2.append(account)
        amounts.append(1000e18)

    market.grantRole('07f9e8c07c8b73fe513688ff4c27d5672674617e83dca1f12879f7b9a12c25de', migrator.address, {'from': acct_adm})
    market.grantRole('af290d8680820aad922855f39b306097b20e28774d6c1ad35a20325630c3a02c', migrator.address, {'from': acct_adm})
    migrator.MigrateUsersList(markets, amounts, addresses_2, {'from': acct_adm})
