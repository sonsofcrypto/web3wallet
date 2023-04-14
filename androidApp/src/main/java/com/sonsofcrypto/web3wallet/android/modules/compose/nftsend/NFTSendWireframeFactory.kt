package com.sonsofcrypto.web3wallet.android.modules.compose.nftsend

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendWireframe
import com.sonsofcrypto.web3walletcore.modules.nftSend.NFTSendWireframeContext
import smartadapter.internal.extension.name

interface NFTSendWireframeFactory {
    fun make(parent: Fragment?, context: NFTSendWireframeContext): NFTSendWireframe
}

class DefaultNFTSendWireframeFactory(
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val confirmationWireframeFactory: ConfirmationWireframeFactory,
): NFTSendWireframeFactory {

    override fun make(
        parent: Fragment?, context: NFTSendWireframeContext
    ): NFTSendWireframe = DefaultNFTSendWireframe(
        parent?.let { WeakRef(it) },
        context,
        networksService,
        currencyStoreService,
        confirmationWireframeFactory,
    )
}

class NFTSendWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register(NFTSendWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultNFTSendWireframeFactory(
                it.resolve(NetworksService::class.name),
                it.resolve(CurrencyStoreService::class.name),
                it.resolve(ConfirmationWireframeFactory::class.name),
            )
        }
    }
}
