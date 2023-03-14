package com.sonsofcrypto.web3wallet.android.modules.compose.networks

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksWireframe
import smartadapter.internal.extension.name

interface NetworksWireframeFactory {
    fun make(parent: Fragment?): NetworksWireframe
}

class DefaultNetworksWireframeFactory(
    private val networksService: NetworksService,
): NetworksWireframeFactory {

    override fun make(parent: Fragment?): NetworksWireframe = DefaultNetworksWireframe(
        parent?.let { WeakRef(it) },
        networksService,
    )
}

class NetworksWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(NetworksWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultNetworksWireframeFactory(
                it.resolve(NetworksService::class.name),
            )
        }
    }
}