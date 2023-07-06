package com.sonsofcrypto.web3lib.services.root

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.Multicall3
import com.sonsofcrypto.web3lib.contract.multiCall3List
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.utils.BigInt

private val ifaceMulticall = Interface.Multicall3()

/** Information about current state of network  */
data class NetworkInfo(
    val blockNumber: BigInt,
    val blockTimestamp: BigInt,
    val basefee: BigInt,
    val blockGasLimit: BigInt
) {
    companion object
}

/** Number of properties (useful for multicall result decoding) */
fun NetworkInfo.Companion.count(): Int = 4

/** MulticallV3 contract Call3 items */
fun NetworkInfo.Companion.callData(multicall3Address: AddressHexString): List<Any> = listOf(
    multiCall3List(multicall3Address, ifaceMulticall, "getBlockNumber"),
    multiCall3List(multicall3Address, ifaceMulticall, "getCurrentBlockTimestamp"),
    multiCall3List(multicall3Address, ifaceMulticall, "getBasefee"),
    multiCall3List(multicall3Address, ifaceMulticall, "getCurrentBlockGasLimit"),
)

/** Decodes result of MulticallV3 call */
fun NetworkInfo.Companion.decodeCallData(data: List<List<Any>>): NetworkInfo {
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