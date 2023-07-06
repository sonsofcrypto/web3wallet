package com.sonsofcrypto.web3lib.services.wallet

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.services.root.NetworkInfo
import com.sonsofcrypto.web3lib.services.root.PollLoopRequest
import com.sonsofcrypto.web3lib.services.root.callData
import com.sonsofcrypto.web3lib.services.root.count
import com.sonsofcrypto.web3lib.services.root.decodeCallData
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.toHexString


interface NetworkPollService {

    /** Fetches balances for address & network info for `Provider.network` */
    suspend fun executePoll(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        pollLoopRequests: List<PollLoopRequest>,
        provider: Provider,
    ): Pair<NetworkInfo, List<BigInt>>
}

class DefaultNetworkPollService: NetworkPollService {

    private val ifaceMulticall = Interface.Multicall3()
    private val ifaceERC20 = Interface.ERC20()
    private val pollLoopRequests: MutableList<PollLoopRequest> = mutableListOf()

    override suspend fun executePoll(
        walletAddress: AddressHexString,
        currencies: List<Currency>,
        requests: List<PollLoopRequest>,
        provider: Provider,
    ): Pair<NetworkInfo, List<BigInt>> {
        val aggregateFn = ifaceMulticall.function("aggregate3")
        val callData = listOf(
            NetworkInfo.callData(provider.network.multicall3Address()) +
            balancesCallData(currencies, walletAddress, provider.network) +
            requests.map { it.toMultiCall3List() }
        )
        val resultData = provider.call(
            provider.network.multicall3Address(),
            ifaceMulticall.encodeFunction(aggregateFn, callData).toHexString(true)
        )
        val result = ifaceMulticall.decodeFunctionResult(
            aggregateFn,
            resultData.toByteArrayData()
        ).first() as List<List<Any>>

        var reqRng = NetworkInfo.count() + currencies.count() to result.count()

        handleNetworkInfo(result)
        handleBalances(result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count()))
        handlePollLoopRequests(requests, result.subList(reqRng.first, reqRng.second))

        return Pair(
            NetworkInfo.decodeCallData(result),
            decodeBalancesCallData(
                result.subList(NetworkInfo.count(), NetworkInfo.count() + currencies.count())
            ),
        )
    }

    private fun handleNetworkInfo(data: List<List<Any>>) {
        NetworkInfo.decodeCallData(data)
    }

    private fun handleBalances(data: List<List<Any>>) {
        data.map {
            ifaceERC20.decodeFunctionResult(
                ifaceERC20.function("balanceOf"),
                it.last() as ByteArray
            ).first() as BigInt
        }
    }

    private fun handlePollLoopRequests(
        requests: List<PollLoopRequest>,
        results: List<List<Any>>
    ){

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