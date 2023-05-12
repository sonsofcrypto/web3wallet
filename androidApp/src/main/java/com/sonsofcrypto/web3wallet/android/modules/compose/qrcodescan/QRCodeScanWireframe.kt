package com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.NavigationFragment
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3walletcore.modules.nftSend.*
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.*

class DefaultQRCodeScanWireframe(
    private val parent: WeakRef<Fragment>?,
    private val context: QRCodeScanWireframeContext,
): QRCodeScanWireframe {

    private lateinit var fragment: WeakRef<Fragment>

    override fun present() {
        val fragment = wireUp()
        parent?.get()?.navigationFragment?.push(fragment, animated = true)
        println("[AA] Pushing DefaultQRCodeScanWireframe")
    }

    override fun navigate(destination: QRCodeScanWireframeDestination) {
        when (destination) {
            is QRCodeScanWireframeDestination.QRCode -> {
                context.handler(destination.value)
            }
            is QRCodeScanWireframeDestination.Dismiss -> {
                println("[AA] Implement -> navigateTo $destination")
            }
        }
    }

    private fun wireUp(): Fragment {
        val view = QRCodeScanFragment()
        val interactor = DefaultQRCodeScanInteractor()
        val presenter = DefaultQRCodeScanPresenter(
            WeakRef(view),
            this,
            interactor,
            context,
        )
        view.presenter = presenter
        return view
    }
}