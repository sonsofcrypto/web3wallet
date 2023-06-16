package com.sonsofcrypto.web3wallet.android.modules.compose.account

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap.CurrencySwapWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.account.*
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframeContext
import com.sonsofcrypto.web3walletcore.services.etherScan.EtherScanService

class DefaultAccountWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: AccountWireframeContext,
    private val currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
    private val currencySendWireframeFactory: CurrencySendWireframeFactory,
    private val currencySwapWireframeFactory: CurrencySwapWireframeFactory,
    private val currencyStoreService: CurrencyStoreService,
    private val walletService: WalletService,
    private val etherScanService: EtherScanService,
): AccountWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.present(fragment, animated = true)
    }

    override fun navigate(destination: AccountWireframeDestination) {
        when (destination) {
            is AccountWireframeDestination.Receive -> {
                val context = CurrencyReceiveWireframeContext(context.network, context.currency)
                currencyReceiveWireframeFactory.make(parent?.get(), context).present()
            }
            is AccountWireframeDestination.Send -> {
                val context = CurrencySendWireframeContext(context.network, null, context.currency)
                currencySendWireframeFactory.make(parent?.get(), context).present()
            }
            is AccountWireframeDestination.Swap -> {
                val context = CurrencySwapWireframeContext(context.network, context.currency, null)
                currencySwapWireframeFactory.make(parent?.get(), context).present()
            }
            is AccountWireframeDestination.More -> {
                println("[AA] Navigate to More...(deep link)")
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = AccountFragment()
        val interactor = DefaultAccountInteractor(
            currencyStoreService,
            walletService,
            etherScanService,
        )
        val presenter = DefaultAccountPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}