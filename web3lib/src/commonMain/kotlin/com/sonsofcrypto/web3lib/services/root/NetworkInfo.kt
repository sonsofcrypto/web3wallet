package com.sonsofcrypto.web3lib.services.root

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.utils.BigInt

private val ifaceMulticall = Interface.Multicall3()

data class NetworkInfo(
    val blockNumber: BigInt,
    val blockTimestamp: BigInt,
    val basefee: BigInt,
    val blockGasLimit: BigInt
) {

    companion object {

        fun callData(multicall3Address: AddressHexString): List<Any> = listOf(
            call3List(multicall3Address, ifaceMulticall, "getBlockNumber"),
            call3List(multicall3Address, ifaceMulticall, "getCurrentBlockTimestamp"),
            call3List(multicall3Address, ifaceMulticall, "getBasefee"),
            call3List(multicall3Address, ifaceMulticall, "getCurrentBlockGasLimit"),
        )

        fun decodeCallData(data: List<List<Any>>): NetworkInfo {
            val blockNumber = ifaceMulticall.decodeFunctionResult(
                ifaceMulticall.function("getBlockNumber"), data[0].last() as ByteArray
            )
            val blockTimestamp = ifaceMulticall.decodeFunctionResult(
                ifaceMulticall.function("getCurrentBlockTimestamp"), data[1].last() as ByteArray
            )
            val basefee = ifaceMulticall.decodeFunctionResult(
                ifaceMulticall.function("getBasefee"), data[2].last() as ByteArray
            )
            val blockGasLimit = ifaceMulticall.decodeFunctionResult(
                ifaceMulticall.function("getCurrentBlockGasLimit"), data[3].last() as ByteArray
            )
            return NetworkInfo(
                blockNumber.first() as BigInt,
                blockTimestamp.first() as BigInt,
                basefee.first() as BigInt,
                blockGasLimit.first() as BigInt,
            )
        }
    }
}

private fun call3List(
    address: AddressHexString,
    iface: Interface,
    fnName: String,
    allowFailure: Boolean = true
): List<Any> = listOf(
    address, allowFailure, iface.encodeFunction(iface.function(fnName))
)