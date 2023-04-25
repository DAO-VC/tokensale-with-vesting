import pytest
from brownie import *
import brownie


@pytest.fixture(scope="module")
def admin(accounts):
    yield accounts[0]


@pytest.fixture(scope="module")
def user(accounts):
    yield accounts[1]


# @pytest.fixture(scope="module")
# def usd_token(admin, erc20Sample):
#     usd_token = admin.deploy(erc20Sample, "Usd", "Usd")
#     yield usd_token


@pytest.fixture(scope="module")
def shark_token(admin, coin):
    shark_token = admin.deploy(coin, "Shark", "SHARK")
    yield shark_token


@pytest.fixture(scope="module")
def treasury(admin, shark_token, Treasury):
    treasury = admin.deploy(Treasury, shark_token.address)
    yield treasury


@pytest.fixture(scope="module")
def market(admin, usd_token, treasury, Market):
    market = admin.deploy(Market, usd_token.address, treasury.address, admin)
    yield market


def test_flow(admin, usd_token, shark_token, treasury, market, user):
    week = 604800

    treasury.transferOwnership(market.address, {'from': admin})
    deploy_new_round(3000, 12 * week, 60 * week, 4 * week, 10, market, admin)  # seed
    deploy_new_round(5000, 12 * week, 60 * week, 4 * week, 12, market, admin)  # Privat
    deploy_new_round(7000, 12 * week, 60 * week, 4 * week, 14, market, admin)  # Strategic
    deploy_new_round(40000, 0 * week, 24 * week, 4 * week, 20, market, admin)  # Public
    deploy_new_round(25000, 0 * week, 32 * week, 4 * week, 17, market, admin)  # Witelist
    shark_token.mint(treasury.address, 1_000_000_000e18, {'from': admin})

    usd_token.mint(user, 1_000e18, {'from': admin})
    assert usd_token.balanceOf(user) == 1_000e18
    usd_token.approve(market.address, 10000000e18, {'from': user})
    usd_token.approve(treasury.address, 10000000e18, {'from': user})

    buy = market.buy(1, 1000e18, user.address, {'from': user})  # set desired shark token amounts
    balance = usd_token.balanceOf(user)/1e18
    assert balance == 988
    assert usd_token.balanceOf(admin) == 1000012e18
    assert shark_token.balanceOf(user) == 50e18
    claim = market.claim({'from': user})
    assert shark_token.balanceOf(user) == 50e18
5_000_000_000_000_000_000

def deploy_new_round(_tge, _cliff, _duration, _slice, _price, market, admin):
    start = 1
    revocable = False
    minOrderSize = 1
    maxOrderSize = 10e27
    permissionLess = True
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, admin)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permissionLess, market, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permissionLess, {'from': acct_adm})
