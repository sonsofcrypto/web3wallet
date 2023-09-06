package com.sonsofcrypto.web3lib.services.currencyStore

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network

fun defaultCurrencies(network: Network): List<Currency> = when (network.chainId) {
    Network.ethereum().chainId -> ethereumDefaultCurrencies
    Network.sepolia().chainId -> sepoliaDefaultCurrencies
    Network.goerli().chainId -> goerliDefaultCurrencies
    else -> emptyList()
}

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
        address = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984",
        coinGeckoId = "uniswap",
    ),
)

val sepoliaDefaultCurrencies = listOf(
    Currency(
        name = "Sepolia Ethereum",
        symbol = "eth",
        decimals = 18u,
        type = Currency.Type.NATIVE,
        address = null,
        coinGeckoId = "ethereum",
    ),
    Currency(
        name = "Sepolia WETH",
        symbol = "weth",
        decimals = 18u,
        type = Currency.Type.ERC20,
        address = "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        coinGeckoId = "weth",
    ),
    Currency(
        name = "Sepolia UNI Token",
        symbol = "uni",
        decimals = 18u,
        type = Currency.Type.ERC20,
        address = "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
        coinGeckoId = "uniswap",
    ),
)

val goerliDefaultCurrencies = listOf(
    Currency(
        name = "Goerli Ethereum",
        symbol = "eth",
        decimals = 18u,
        type = Currency.Type.NATIVE,
        address = null,
        coinGeckoId = "ethereum",
    ),
    Currency(
        name = "Goerli Tether",
        symbol = "usdt",
        decimals = 6u,
        type = Currency.Type.ERC20,
        address = "0x509Ee0d083DdF8AC028f2a56731412edD63223B9",
        coinGeckoId = "tether",
    ),
)
