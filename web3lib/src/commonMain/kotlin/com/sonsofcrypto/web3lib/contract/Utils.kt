package com.sonsofcrypto.web3lib.contract

import com.sonsofcrypto.web3lib.types.AddressHexString

fun multiCall3List(
    address: AddressHexString,
    iface: Interface,
    fnName: String,
    values: List<Any> = emptyList(),
    allowFailure: Boolean = true
): List<Any> = listOf(
    address, allowFailure, iface.encodeFunction(iface.function(fnName), values)
)

data class Call3(
    val address: AddressHexString,
    val allowFailure: Boolean,
    val calldata: ByteArray,
) {
    fun toList(): List<Any> = listOf(address, allowFailure, calldata)
}