package com.sonsofcrypto.web3walletcore.modules.qrCodeScan

data class QRCodeScanWireframeContext(
    val type: Type,
    val handler: (String) -> Unit,
) {
    sealed class Type {
        data class Network(val network: com.sonsofcrypto.web3lib.types.Network): Type()
        object Default: Type()
    }
}

sealed class QRCodeScanWireframeDestination {
    data class QRCode(val value: String): QRCodeScanWireframeDestination()
    object Dismiss: QRCodeScanWireframeDestination()
}

interface QRCodeScanWireframe {
    fun present()
    fun navigate(destination: QRCodeScanWireframeDestination)
}