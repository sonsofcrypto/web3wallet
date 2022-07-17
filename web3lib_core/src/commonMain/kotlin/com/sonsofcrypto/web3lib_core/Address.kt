package com.sonsofcrypto.web3lib_core

typealias AddressBytes = ByteArray

/** Address */
sealed class Address() {
    data class BytesAddress(val data: AddressBytes) : Address()
    data class HexString(val hexString: String) : Address()
    data class Name(val name: String) : Address()
}