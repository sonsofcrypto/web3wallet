package com.sonsofcrypto.web3wallet.android.modules.root

import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.degen.DegenWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.keystore.KeyStoreWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsdashboard.NFTsDashboardWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.dashboard.DashboardWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframe
import smartadapter.internal.extension.name

interface RootWireframeFactory {
    fun make(parent: AppCompatActivity?): RootWireframe
}

class DefaultRootWireframeFactory(
    private val keyStoreWireframeFactory: KeyStoreWireframeFactory,
    private val dashboardWireframeFactory: DashboardWireframeFactory,
    private val degenWireframeFactory: DegenWireframeFactory,
    private val nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory,
): RootWireframeFactory {

    override fun make(parent: AppCompatActivity?): RootWireframe = DefaultRootWireframe(
        parent,
        keyStoreWireframeFactory,
        dashboardWireframeFactory,
        degenWireframeFactory,
        nftsDashboardWireframeFactory,
    )
}

class RootWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register(RootWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultRootWireframeFactory(
                it.resolve(KeyStoreWireframeFactory::class.name),
                it.resolve(DashboardWireframeFactory::class.name),
                it.resolve(DegenWireframeFactory::class.name),
                it.resolve(NFTsDashboardWireframeFactory::class.name)
            )
        }
    }
}