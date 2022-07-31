package com.sonsofcrypto.web3lib.services.currencies.model

import com.sonsofcrypto.web3lib.types.Currency

val ethereumDefaultCurrencies = listOf(
    Currency(
        name = "Ethereum", symbol = "eth",
        decimals = 18u,
        type = Currency.Type.NATIVE,
        address = null,
        coinGeckoId = "ethereum",
    ),
    Currency(
        name = "Cult DAO",
        symbol = "cult",
        decimals = 18u,
        type = Currency.Type.ERC20,
        address = "0xf0f9d895aca5c8678f706fb8216fa22957685a13",
        coinGeckoId = "cult-dao",
    ),
    Currency(
        name = "Tether",
        symbol = "usdt",
        decimals = 6u,
        type = Currency.Type.ERC20,
        address = "0xdac17f958d2ee523a2206206994597c13d831ec7",
        coinGeckoId = "tether",
    ),
    Currency(
        name = "Uniswap",
        symbol = "uni",
        decimals = 18u,
        type = Currency.Type.ERC20,
        address = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
        coinGeckoId = "uniswap",
    ),
)

val ropstenDefaultCurrencies = listOf(
    Currency(
        name = "Ropsten Ethereum",
        symbol = "eth",
        decimals = 18u,
        type = Currency.Type.NATIVE,
        address = null,
        coinGeckoId = "ethereum",
    )
)