package com.sonsofcrypto.web3wallet.android.modules.compose.nftscollection

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail.NFTDetailWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframe
import com.sonsofcrypto.web3walletcore.modules.nftsCollection.NFTsCollectionWireframeContext
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import smartadapter.internal.extension.name

interface NFTsCollectionWireframeFactory {
    fun make(
        parent: Fragment?, context: NFTsCollectionWireframeContext
    ): NFTsCollectionWireframe
}

class DefaultNFTsCollectionWireframeFactory(
    private val nfTsService: NFTsService,
    private val nftDetailWireframeFactory: NFTDetailWireframeFactory,
): NFTsCollectionWireframeFactory {

    override fun make(
        parent: Fragment?, context: NFTsCollectionWireframeContext
    ): NFTsCollectionWireframe {
        return DefaultNFTsCollectionWireframe(
            parent?.let { WeakRef(it) },
            context,
            nfTsService,
            nftDetailWireframeFactory,
        )
    }
}

class NFTsCollectionWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(NFTsCollectionWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {

            DefaultNFTsCollectionWireframeFactory(
                it.resolve(NFTsService::class.name),
                it.resolve(NFTDetailWireframeFactory::class.name),
            )
        }
    }
}