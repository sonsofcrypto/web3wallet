package com.sonsofcrypto.web3wallet.android.modules.compose.currencysend

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3walletcore.modules.currencySend.*

class DefaultCurrencySendWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencySendWireframeContext,
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
): CurrencySendWireframe {

    override fun present() {
        val fragment = wireUp()
        (parent?.get() as? NavigationFragment)?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencySendWireframeDestination) {
        println("Implement navigation to $destination")
    }

    private fun wireUp(): Fragment {
        val view = CurrencySendFragment()
        val interactor = DefaultCurrencySendInteractor(
            walletService,
            networksService,
            currencyStoreService,
        )
        val presenter = DefaultCurrencySendPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}