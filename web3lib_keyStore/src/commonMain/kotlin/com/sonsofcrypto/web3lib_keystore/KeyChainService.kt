package com.sonsofcrypto.web3lib_keystore

enum class ServiceType {
    PASSWORD, SECRET_STORAGE, UNDEFINED;

    fun serviceString(): String = when (this) {
        PASSWORD -> "com.sonsOfCrypto.web3Wallet.password"
        SECRET_STORAGE -> "com.sonsOfCrypto.web3Wallet.secreteStorage"
        UNDEFINED -> "com.sonsOfCrypto.web3Wallet.undefined"
    }
}

/** Exceptions */
sealed class KeyChainServiceErr(
    message: String? = null,
    cause: Throwable? = null
) : Exception(message, cause) {
    constructor(cause: Throwable) : this(null, cause)

    data class SetErr(val info: String) : KeyChainServiceErr("Set Error: $info")
    data class GetErr(val info: String) : KeyChainServiceErr("Get Error: $info")
    object GetNoDataErr: KeyChainServiceErr("Get no data error")
}


interface KeyChainService {
    @Throws(KeyChainServiceErr::class)
    fun get(id: String, type: ServiceType): ByteArray
    @Throws(KeyChainServiceErr::class)
    fun set(id: String, data: ByteArray, type: ServiceType, icloud: Boolean)
    fun remove(id: String, type: ServiceType)
}
