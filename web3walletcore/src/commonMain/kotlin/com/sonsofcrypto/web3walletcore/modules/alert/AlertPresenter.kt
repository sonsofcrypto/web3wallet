package com.sonsofcrypto.web3walletcore.modules.alert

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeDestination.Dismiss

sealed class AlertPresenterEvent {
    data class SelectAction(val idx: Int): AlertPresenterEvent()
    object Dismiss: AlertPresenterEvent()
}

interface AlertPresenter {
    fun present()
    fun handle(event: AlertPresenterEvent)
}

class DefaultAlertPresenter(
    private val view: WeakRef<AlertView>,
    private val wireframe: AlertWireframe,
    private val context: AlertWireframeContext
): AlertPresenter {

    override fun present() { updateView() }

    override fun handle(event: AlertPresenterEvent) {
        when (event) {
            is AlertPresenterEvent.SelectAction -> {
                context.onActionTapped?.let { it(event.idx) }
                handle(AlertPresenterEvent.Dismiss)
            }
            is AlertPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView() {
        view.get()?.update(AlertViewModel(context))
    }
}
