package com.sonsofcrypto.web3wallet.android.modules.root

import androidx.appcompat.app.AppCompatActivity
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.dashboard.DashboardWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.degen.DegenWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsdashboard.NFTsDashboardWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.root.RootWireframe
import smartadapter.internal.extension.name

interface RootWireframeFactory {
    fun make(parent: AppCompatActivity?): RootWireframe
}

class DefaultRootWireframeFactory(
    private var dashboardWireframeFactory: DashboardWireframeFactory,
    private var degenWireframeFactory: DegenWireframeFactory,
    private var nftsDashboardWireframeFactory: NFTsDashboardWireframeFactory,
): RootWireframeFactory {

    override fun make(parent: AppCompatActivity?): RootWireframe = DefaultRootWireframe(
        parent,
        dashboardWireframeFactory,
        degenWireframeFactory,
        nftsDashboardWireframeFactory,
    )
}

class RootWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register(RootWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultRootWireframeFactory(
                it.resolve(DashboardWireframeFactory::class.name),
                it.resolve(DegenWireframeFactory::class.name),
                it.resolve(NFTsDashboardWireframeFactory::class.name)
            )
        }
    }
}