package com.sonsofcrypto.web3lib_keystore

actual class DefaultKeyChainService: KeyChainService {

    @Throws(KeyChainServiceErr::class)
    override fun get(id: String, type: ServiceType): ByteArray {
        TODO("implement")
    }

    @Throws(KeyChainServiceErr::class)
    override fun set(id: String, data: ByteArray, type: ServiceType, icloud: Boolean) {
        TODO("implement")
    }

    override fun remove(id: String, type: ServiceType) {
        TODO("implement")
    }
}