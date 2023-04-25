 
    market = Market.deploy(usd_token.address, treasury.address, acct_adm, {'from': acct_adm})
    
    proxy_admin = ProxyAdmin.deploy(
        {"from":  acct_adm},
    )

    # If we want an intializer function we can add
    # `initializer=market.store, 1`
    # to simulate the initializer being the `store` function
    # with a `newValue` of 1
    market_encoded_initializer_function = encode_function_data()
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    proxy = TransparentUpgradeableProxy.deploy(
        market.address,
        # account.address,
        proxy_admin.address,
        market_encoded_initializer_function,
        {"from": account, "gas_limit": 1000000},
    )
    print(f"Proxy deployed to {proxy} ! You can now upgrade it to marketV2!")
    proxy_market = Contract.from_abi("market", proxy.address, market.abi)
    print(f"Here is the initial value in the market: {proxy_market.retrieve()}")
    
    
      
    treasury = Treasury.deploy(shark_token.address, {'from': acct_adm})
    
    proxy_admin = ProxyAdmin.deploy(
        {"from":  acct_adm},
    )

    # If we want an intializer function we can add
    # `initializer=market.store, 1`
    # to simulate the initializer being the `store` function
    # with a `newValue` of 1
    treasury_encoded_initializer_function = encode_function_data(shark_token.address)
    # market_encoded_initializer_function = encode_function_data(initializer=market.store, 1)
    proxy = TransparentUpgradeableProxy.deploy(
        market.address,
        # account.address,
        proxy_admin.address,
        treasury_encoded_initializer_function,
        {"from": acct_adm}, # "gas_limit": 1000000
    )
    print(f"Proxy deployed to {proxy} ! You can now upgrade it to marketV2!")
    proxy_market = Contract.from_abi("market", proxy.address, market.abi)
    print(f"Here is the initial value in the market: {proxy_market.retrieve()}")
