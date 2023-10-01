package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3lib.utils.withUICxt
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsServiceListener
import com.sonsofcrypto.web3walletcore.services.settings.NFTCarouselSize
import com.sonsofcrypto.web3walletcore.services.settings.NFTCarouselSize.*
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

interface NFTsDashboardInteractorLister {
    fun networkChanged()
    fun nftsChanged()
}

interface NFTsDashboardInteractor {
    @Throws(Throwable::class)
    suspend fun fetchYourNFTs()
    fun nfts(): List<NFTItem>
    fun collections(): List<NFTCollection>
    fun regularCarousel(): Boolean
    fun add(listener: NFTsDashboardInteractorLister)
    fun remove(listener: NFTsDashboardInteractorLister)
}

class DefaultNFTsDashboardInteractor(
    private val networksService: NetworksService,
    private val nftsService: NFTsService,
    private val settingsService: SettingsService,
): NFTsDashboardInteractor, NetworksListener, NFTsServiceListener {
    private var nfts: List<NFTItem> = emptyList()
    private var collections: List<NFTCollection> = emptyList()
    private var listener: NFTsDashboardInteractorLister? = null

    override suspend fun fetchYourNFTs() {
        nftsService.fetchNFTs()
        withUICxt {
            nfts = nftsService.nfts()
            collections = nftsService.collections()
        }
    }

    override fun nfts(): List<NFTItem> = nfts
    override fun collections(): List<NFTCollection> = collections
    override fun regularCarousel(): Boolean =
        settingsService.nftCarouselSize == REGULAR

    override fun add(listener: NFTsDashboardInteractorLister) {
        if (this.listener != null) { remove(this.listener!!)}
        this.listener = listener
        networksService.add(this)
        nftsService.addListener(this)
    }

    override fun remove(listener: NFTsDashboardInteractorLister) {
        this.listener = null
        networksService.remove(this)
        nftsService.removeListener(this)
    }

    override fun handle(event: NetworksEvent) {
        if (event is NetworksEvent.NetworkDidChange) listener?.networkChanged()
    }

    override fun nftsChanged() {
        CoroutineScope(uiDispatcher).launch {
            nfts = nftsService.nfts()
            collections = nftsService.collections()
            listener?.nftsChanged()
        }
    }
}
