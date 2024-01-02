package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.types.Network

class NetworkAddressFormatter {

    fun format(
        address: String,
        digits: Int = 8,
        network: Network = Network.ethereum()
    ): String {
        val l = address.length
        if (l == 0) {
            return "0x"
        }
        return when (network.name.lowercase()) {
            "ethereum" -> {
                address.dropLast(l - (2 + digits)) + "..." + address.drop(l - digits)
            }
            else  -> {
                address.dropLast(l - (2 + digits)) + "..." + address.drop(l - digits)
            }
        }
    }
}