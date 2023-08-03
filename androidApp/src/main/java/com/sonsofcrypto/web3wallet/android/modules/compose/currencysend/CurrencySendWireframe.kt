package com.sonsofcrypto.web3wallet.android.modules.compose.currencysend

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.assembler
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.confirmation.ConfirmationWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan.QRCodeScanWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySend.*
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeDestination.*
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanWireframeContext
import smartadapter.internal.extension.name

class DefaultCurrencySendWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: CurrencySendWireframeContext,
    private val walletService: WalletService,
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
    private val confirmationWireframeFactory: ConfirmationWireframeFactory,
    private val qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
): CurrencySendWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: CurrencySendWireframeDestination) {
        when (destination) {
            is QrCodeScan -> {
                val context = QRCodeScanWireframeContext(
                    type = QRCodeScanWireframeContext.Type.Network(network = context.network),
                    handler = onPopWrapped(onCompletion = destination.onCompletion)
                )
                qrCodeScanWireframeFactory.make(parent?.get(), context).present()
            }
            is SelectCurrency -> {
                val context = CurrencyPickerWireframeContext(
                    isMultiSelect = false,
                    showAddCustomCurrency = false,
                    networksData = listOf(
                        CurrencyPickerWireframeContext.NetworkData(Network.ethereum(), null, null)
                    ),
                    selectedNetwork = Network.ethereum(),
                    handler = { result -> result.currency?.let { destination.onCompletion(it) } }
                )
                currencyPickerWireframeFactory.make(parent?.get(), context).present()
            }
            is ConfirmSend -> {
                confirmationWireframeFactory.make(parent?.get(), destination.context).present()
            }
            is Back -> { parent?.navigationFragment?.popOrDismiss() }
            is Dismiss -> { parent?.navigationFragment?.dismiss() }
            else -> {
                println("[AA] Implement -> $destination")
            }
        }
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

    private fun onPopWrapped(onCompletion: (String) -> Unit): (String) -> Unit = { addressTo ->
        parent?.get().navigationFragment?.dismiss(
            onCompletion = { onCompletion(addressTo) }
        )
    }
}

private val List<CurrencyPickerWireframeContext.Result>.currency: Currency? get() = firstOrNull()
    ?.selectedCurrencies?.firstOrNull()
