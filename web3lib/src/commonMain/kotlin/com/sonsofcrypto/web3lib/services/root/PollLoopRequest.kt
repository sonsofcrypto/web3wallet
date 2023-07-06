package com.sonsofcrypto.web3lib.services.root

import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.multiCall3List
import com.sonsofcrypto.web3lib.types.AddressHexString

class PollLoopRequest(
    val address: AddressHexString,
    val iface: Interface,
    val fnName: String,
    val values: List<Any> = emptyList(),
    val handler: (List<Any>)->Unit,
) {

    fun toMultiCall3List(): List<Any> =
        multiCall3List(address, iface, fnName, values)
}