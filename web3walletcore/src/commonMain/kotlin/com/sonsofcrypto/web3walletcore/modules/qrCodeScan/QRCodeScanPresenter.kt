package com.sonsofcrypto.web3walletcore.modules.qrCodeScan

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanWireframeDestination.Dismiss

sealed class QRCodeScanPresenterEvent {
    data class QRCode(val input: String): QRCodeScanPresenterEvent()
    object Dismiss: QRCodeScanPresenterEvent()
}

interface QRCodeScanPresenter {
    fun present()
    fun viewWillAppear()
    fun handle(event: QRCodeScanPresenterEvent)
}

class DefaultQRCodeScanPresenter(
    private val view: WeakRef<QRCodeScanView>,
    private val wireframe: QRCodeScanWireframe,
    private val interactor: QRCodeScanInteractor,
    private val context: QRCodeScanWireframeContext,
): QRCodeScanPresenter {
    private var qrCodeDetected = false

    override fun present() {
        updateView()
    }

    override fun viewWillAppear() {
        qrCodeDetected = false
    }

    override fun handle(event: QRCodeScanPresenterEvent) {
        when (event) {
            is QRCodeScanPresenterEvent.QRCode -> handleQRCodeEvent(event.input)
            is QRCodeScanPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView(failure: String? = null) {
        view.get()?.update(viewModel(failure))
    }

    private fun viewModel(failure: String?): QRCodeScanViewModel =
        QRCodeScanViewModel(Localized("qrCodeScan.title"), failure)

    private fun handleQRCodeEvent(input: String) {
        when (val c = context.type) {
            is QRCodeScanWireframeContext.Type.Default -> handleQRCode(input)
            is QRCodeScanWireframeContext.Type.Network -> {
                val address = interactor.validateAddress(input, c.network)
                if (address != null) { handleQRCode(address) }
                else { updateView(Localized("qrCodeScan.error.invalid.address", c.network.name))}
            }
        }
    }

    private fun handleQRCode(qrCode: String) {
        if (qrCodeDetected) return
        qrCodeDetected = true
        wireframe.navigate(QRCodeScanWireframeDestination.QRCode(qrCode))
    }
}