package com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.AssemblerComponent
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistry
import com.sonsofcrypto.web3wallet.android.common.AssemblerRegistryScope
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanWireframe
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanWireframeContext
import smartadapter.internal.extension.name

interface QRCodeScanWireframeFactory {
    fun make(parent: Fragment?, context: QRCodeScanWireframeContext): QRCodeScanWireframe
}

class DefaultQRCodeScanWireframeFactory: QRCodeScanWireframeFactory {

    override fun make(
        parent: Fragment?, context: QRCodeScanWireframeContext
    ): QRCodeScanWireframe = DefaultQRCodeScanWireframe(
        parent?.let { WeakRef(it) },
        context,
    )
}

class QRCodeScanWireframeFactoryAssembler: AssemblerComponent {

    override fun register(to: AssemblerRegistry) {
        to.register(QRCodeScanWireframeFactory::class.name, AssemblerRegistryScope.INSTANCE) {
            DefaultQRCodeScanWireframeFactory()
        }
    }
}
