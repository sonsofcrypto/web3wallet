package com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.nftsend.NFTSendWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframe
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeContext
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import smartadapter.internal.extension.name

interface NFTDetailWireframeFactory {
    fun make(parent: Fragment?, context: NFTDetailWireframeContext): NFTDetailWireframe
}

class DefaultNFTDetailWireframeFactory(
    private val nftsService: NFTsService,
    private val nftSendWireframeFactory: NFTSendWireframeFactory,
    private val networksService: NetworksService,
): NFTDetailWireframeFactory {

    override fun make(parent: Fragment?, context: NFTDetailWireframeContext): NFTDetailWireframe {
        return DefaultNFTDetailWireframe(
            parent?.let { WeakRef(it) },
            context,
            nftsService,
            nftSendWireframeFactory,
            networksService,
        )
    }
}

class NFTDetailWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(NFTDetailWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {

            DefaultNFTDetailWireframeFactory(
                it.resolve(NFTsService::class.name),
                it.resolve(NFTSendWireframeFactory::class.name),
                it.resolve(NetworksService::class.name),
            )
        }
    }
}