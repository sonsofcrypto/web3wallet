package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsServiceListener

interface NFTsDashboardInteractorLister {
    fun networkChanged()
    fun nftsChanged()
}

interface NFTsDashboardInteractor {
    @Throws(Throwable::class)
    suspend fun fetchYourNFTs(isPullDownToRefreh: Boolean): List<NFTItem>
    fun yourCollections(): List<NFTCollection>
    fun add(listener: NFTsDashboardInteractorLister)
    fun remove(listener: NFTsDashboardInteractorLister)
}

class DefaultNFTsDashboardInteractor(
    private val networksService: NetworksService,
    private val nftsService: NFTsService,
): NFTsDashboardInteractor, NetworksListener, NFTsServiceListener {
    private var listener: NFTsDashboardInteractorLister? = null

    override suspend fun fetchYourNFTs(isPullDownToRefreh: Boolean): List<NFTItem> {
        if (!isPullDownToRefreh) return nftsService.yourNFTs()
        return nftsService.fetchNFTs()
    }

    override fun yourCollections(): List<NFTCollection> = nftsService.yourCollections()

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
        listener?.nftsChanged()
    }
}
