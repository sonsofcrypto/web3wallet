package com.sonsofcrypto.web3walletcore.modules.currencyReceive

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeDestination.Back
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeDestination.Dismiss

sealed class CurrencyReceivePresenterEvent {
    object Back: CurrencyReceivePresenterEvent()
    object Dismiss: CurrencyReceivePresenterEvent()
}

interface CurrencyReceivePresenter {
    fun present()
    fun handle(event: CurrencyReceivePresenterEvent)
}

class DefaultCurrencyReceivePresenter(
    private val view: WeakRef<CurrencyReceiveView>,
    private val wireframe: CurrencyReceiveWireframe,
    private val interactor: CurrencyReceiveInteractor,
    private val context: CurrencyReceiveWireframeContext,
): CurrencyReceivePresenter {

    override fun present() {
        updateView()
    }

    override fun handle(event: CurrencyReceivePresenterEvent) {
        when (event) {
            is CurrencyReceivePresenterEvent.Back -> wireframe.navigate(Back)
            is CurrencyReceivePresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView() { view.get()?.update(viewModel()) }

    private fun viewModel(): CurrencyReceiveViewModel =
        CurrencyReceiveViewModel(
            Localized("currencyReceive.title.receive", context.currency.symbol.uppercase()),
            Localized("currencyReceive.qrcode.name"),
            context.currency.symbol.uppercase(),
            interactor.receivingAddress(context.network, context.currency) ?: "❌",
            disclaimer
        )

    private val disclaimer: String get() {
        val name = context.network.name.replaceFirstChar {
            if (it.isLowerCase()) it.titlecase() else it.toString()
        }
        val symbol = context.currency.symbol.uppercase()
        return Localized("currencyReceive.disclaimer", "$name ($symbol)")
    }
}