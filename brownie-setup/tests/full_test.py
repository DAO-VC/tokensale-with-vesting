import pytest
from brownie import *
import brownie

week = 604800


@pytest.fixture(scope="function")
def admin(accounts):
    yield accounts[0]


@pytest.fixture(scope="function")
def user(accounts):
    yield accounts[1]


@pytest.fixture(scope="function")
def usd_token(admin, erc20Sample):
    usd_token = admin.deploy(erc20Sample, "Usd", "Usd")
    yield usd_token


@pytest.fixture(scope="function")
def shark_token(admin, erc20Sample):
    shark_token = admin.deploy(erc20Sample, "Shark", "SHARK")
    yield shark_token


@pytest.fixture(scope="function")
def treasury(admin, shark_token, Treasury):
    treasury = admin.deploy(Treasury, shark_token.address)
    yield treasury


@pytest.fixture(scope="function")
def market(admin, usd_token, treasury, Market):
    market = admin.deploy(Market, usd_token.address, treasury.address, admin)
    treasury.transferOwnership(market.address, {'from': admin})
    yield market


def test_strait_flow(admin, usd_token, shark_token, treasury, market, user):
    assert usd_token.balanceOf(user) == 1_000e18
    buy = market.buy(1, 83e18, user.address, {'from': user})  # set desired shark token amounts
    vestsched = market.getVestingSchedules(user, 1)
    balance = usd_token.balanceOf(user)/1e18
    total = market.getMarketInfo(1)
    assert balance == 987
    assert usd_token.balanceOf(admin) == 1000012e18
    assert shark_token.balanceOf(user) == 50e18

    schedules = treasury.getVestingSchedulesCountByBeneficiary(user, 1, {'from': admin})
    schedule_id = treasury.computeVestingScheduleIdForAddressAndIndex(user, 0, {'from': admin})
    v_schedule = treasury.getVestingSchedule(schedule_id, 1,  {'from': admin})
    compute_unlock = treasury.computeReleasableAmount(schedule_id, 1, {'from': admin})

    chain.sleep((12 + 4) * week)
    release_amount = treasury.computeReleasableAmountTest(schedule_id, 1, {'from': admin})
    assert release_amount.return_value/10e10 == int(v_schedule[7] * (v_schedule[5] / v_schedule[4]))/10e10
    claim = market.claim(1, {'from': user})
    v_schedule1 = treasury.getVestingSchedule(schedule_id, 1, {'from': admin})
    chain.sleep(46 * week)
    release_amount1 = treasury.computeReleasableAmountTest(schedule_id, 1, {'from': admin})
    assert release_amount1.return_value / 10e10 == v_schedule1[7] / 10e10 - v_schedule1[9] / 10e10  # - release_amount.return_value/10e10
    claim = market.claim(1, {'from': user})
    assert shark_token.balanceOf(user) == 1000e18


# def test_err_flow(admin, usd_token, shark_token, treasury, market, user):
#     assert usd_token.balanceOf(user) == 1_000e18
#     buy = market.buy(1, 1000e18, user.address, {'from': user})  # set desired shark token amounts
#     balance = int(usd_token.balanceOf(user)/1e18)
#     schedule_id = treasury.computeVestingScheduleIdForAddressAndIndex(user, 0, {'from': admin})
#     release_amount = treasury.computeReleasableAmountTest(schedule_id, 1, {'from': admin})
#     assert balance == 987
#     assert release_amount == 0
#     assert market.avaibleToClaim(1, user) == 0

# def test_several_vesting(admin, usd_token, shark_token, treasury, market, user):
#     assert usd_token.balanceOf(user) == 1_000e18
#
#     buy1 = market.buy(1, 1000e18, user.address, {'from': user})
#     buy2 = market.buy(1, 1000e18, user.address, {'from': user})
#     assert shark_token.balanceOf(user) == 100e18
#     chain.sleep((12 + 4) * week)
#
#     claim = market.claim({'from': user})
#     assert shark_token.balanceOf(user) == 200e18


@pytest.fixture(autouse=True, scope="function")
def init(admin, usd_token, shark_token, treasury, market, user):

    deploy_new_round(_tge=3000, _cliff=12 * week, _duration=60 * week, _slice=4 * week, _price=10, market=market,
                     admin=admin)  # seed
    deploy_new_round(5000, 12 * week, 60 * week, 4 * week, 12, market, admin)  # Private
    deploy_new_round(7000, 12 * week, 60 * week, 4 * week, 14, market, admin)  # Strategic
    deploy_new_round(40000, 0 * week, 24 * week, 4 * week, 20, market, admin)  # Public
    deploy_new_round(25000, 0 * week, 32 * week, 4 * week, 17, market, admin)  # Whitelist
    shark_token.mint(treasury.address, 1_000_000_000e18, {'from': admin})

    usd_token.mint(user, 1_000e18, {'from': admin})
    usd_token.approve(market.address, 10000000e18, {'from': user})
    usd_token.approve(treasury.address, 10000000e18, {'from': user})


def deploy_new_round(_tge, _cliff, _duration, _slice, _price, market, admin):
    start = 1681802219
    revocable = False
    minOrderSize = 1
    maxOrderSize = 10e27
    permissionLess = True
    deployRound(_price, minOrderSize, maxOrderSize, _tge, start, _cliff, _duration, _slice, revocable, permissionLess, market, admin)


def deployRound(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permissionLess, market, acct_adm):
    market.deployMarket(price, minOrderSize, maxOrderSize, tgeRatio, start, cliff, duration, slicePeriod, revocable, permissionLess, {'from': acct_adm})
