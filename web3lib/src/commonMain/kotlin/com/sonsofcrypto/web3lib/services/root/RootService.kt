package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.currencyStore.sepoliaDefaultCurrencies
import com.sonsofcrypto.web3lib.services.root.NetworkInfo
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import kotlinx.coroutines.runBlocking

interface RootService {

    /** Fetches balances for address & network info for `Provider.network` */
    suspend fun executePool(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        provider: Provider,
    ): Pair<List<BigInt>, NetworkInfo>

}

class DefaultRootService: RootService {

    private val ifaceMulticall = Interface.Multicall3()
    private val ifaceERC20 = Interface.ERC20()

    // GasPrice
    // Optional transacitonCount

    override suspend fun executePool(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        provider: Provider,
    ): Pair<List<BigInt>, NetworkInfo> {
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val callData = ifaceMulticall.encodeFunction(
            aggregateFn,
            listOf(
                NetworkInfo.callData(provider.network.multicall3Address()) +
                balancesCallData(currencies, walletAddress, provider.network)
            )
        )
        val resultData = provider.call(
            provider.network.multicall3Address(),
            callData.toHexString(true)
        )
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        ).first() as List<List<Any>>

        return Pair(
            decodeBalancesCallData(result.subList(4, result.count())),
            NetworkInfo.decodeCallData(result),
        )
    }

    fun balancesCallData(
        currencies: List<Currency>,
        walletAddress: String,
        network: Network
    ): List<Any> {
        val balanceOfCallData = ifaceERC20.encodeFunction(
            ifaceERC20.function("balanceOf"),
            listOf(walletAddress)
        )
        val nativeBalanceCallData = ifaceMulticall.encodeFunction(
            ifaceMulticall.function("getEthBalance"),
            listOf(walletAddress)
        )
        return currencies.map {
            if (it.isNative())
                listOf(network.multicall3Address(), true, nativeBalanceCallData)
            else
                listOf(it.address, true, balanceOfCallData)
        }
    }

    fun decodeBalancesCallData(data: List<List<Any>>): List<BigInt> = data.map {
        ifaceERC20.decodeFunctionResult(
            ifaceERC20.function("balanceOf"),
            it.last() as ByteArray
        ).first() as BigInt
    }
}