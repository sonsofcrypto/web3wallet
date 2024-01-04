package com.sonsofcrypto.web3walletcore.modules.degen

import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.services.networks.NetworksListener
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3walletcore.services.degen.DAppCategory
import com.sonsofcrypto.web3walletcore.services.degen.DegenService

interface DegenInteractorLister {
    fun handle(event: NetworksEvent)
}

interface DegenInteractor {
    val categoriesActive: List<DAppCategory>
    val categoriesInactive: List<DAppCategory>
    fun isVoidSigner(): Boolean
    fun add(listener: DegenInteractorLister)
    fun remove(listener: DegenInteractorLister)
}

class DefaultDegenInteractor(
    private val degenService: DegenService,
    private val networksService: NetworksService,
    private val walletService: WalletService,
): DegenInteractor, NetworksListener {
    private var listener: DegenInteractorLister? = null

    override val categoriesActive: List<DAppCategory> get() = degenService.categoriesActive()

    override val categoriesInactive: List<DAppCategory> get() = degenService.categoriesInactive()

    override fun isVoidSigner(): Boolean =
        walletService.isSelectedVoidSigner()

    override fun add(listener: DegenInteractorLister) {
        if (this.listener != null) { networksService.remove(this) }
        this.listener = listener
        networksService.add(this)
    }

    override fun remove(listener: DegenInteractorLister) {
        this.listener = null
        networksService.remove(this)
    }

    override fun handle(event: NetworksEvent) {
        listener?.handle(event)
    }
}
