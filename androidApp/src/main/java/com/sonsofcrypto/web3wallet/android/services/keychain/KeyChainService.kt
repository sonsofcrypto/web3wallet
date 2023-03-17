package com.sonsofcrypto.web3wallet.android.services.keychain

import com.sonsofcrypto.web3lib.services.keyStore.KeyChainService
import com.sonsofcrypto.web3lib.services.keyStore.ServiceType
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope

class DefaultKeyChainService: KeyChainService {

    override fun get(id: String, type: ServiceType): ByteArray {
        println("[AA] KeyChainService.get($id) NOT IMPLEMENTED")
        return ByteArray(0)
    }

    override fun set(id: String, data: ByteArray, type: ServiceType, icloud: Boolean) {
        println("[AA] KeyChainService.set($id) NOT IMPLEMENTED")
    }

    override fun remove(id: String, type: ServiceType) {
        println("[AA] KeyChainService.remove($id) NOT IMPLEMENTED")
    }

    override fun biometricsSupported(): Boolean {
        println("[AA] KeyChainService.biometricsSupported() NOT IMPLEMENTED")
        return true
    }

    override fun biometricsAuthenticate(title: String, handler: (Boolean, Error?) -> Unit) {
        println("[AA] KeyChainService.biometricsAuthenticate() NOT IMPLEMENTED")
    }
}