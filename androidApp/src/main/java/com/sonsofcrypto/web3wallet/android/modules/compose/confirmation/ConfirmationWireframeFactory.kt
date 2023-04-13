package com.sonsofcrypto.web3wallet.android.modules.compose.confirmation

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframe
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframeContext
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService
import smartadapter.internal.extension.name

interface ConfirmationWireframeFactory {
    fun make(parent: Fragment?, context: ConfirmationWireframeContext): ConfirmationWireframe
}

class DefaultConfirmationWireframeFactory(
    private val walletService: WalletService,
    private val nftsService: NFTsService,
    private val currencyStoreService: CurrencyStoreService,
): ConfirmationWireframeFactory {

    override fun make(
        parent: Fragment?, context: ConfirmationWireframeContext
    ): ConfirmationWireframe = DefaultConfirmationWireframe(
        parent?.let { WeakRef(it) },
        context,
        walletService,
        nftsService,
        currencyStoreService,
    )
}

class ConfirmationWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {

        to.register(ConfirmationWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultConfirmationWireframeFactory(
                it.resolve(WalletService::class.name),
                it.resolve(NFTsService::class.name),
                it.resolve(CurrencyStoreService::class.name),
            )
        }
    }
}