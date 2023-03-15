package com.sonsofcrypto.web3wallet.android.modules.compose.keystore

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreWireframe
import smartadapter.internal.extension.name

interface KeyStoreWireframeFactory {
    fun make(parent: Fragment?): KeyStoreWireframe
}

class DefaultKeyStoreWireframeFactory(
    private val keyStoreService: KeyStoreService,
    private val networksService: NetworksService,
): KeyStoreWireframeFactory {

    override fun make(parent: Fragment?): KeyStoreWireframe = DefaultKeyStoreWireframe(
        parent?.let { WeakRef(it) },
        keyStoreService,
        networksService,
    )
}

class KeyStoreWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(KeyStoreWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultKeyStoreWireframeFactory(
                it.resolve(KeyStoreService::class.name),
                it.resolve(NetworksService::class.name),
            )
        }
    }
}