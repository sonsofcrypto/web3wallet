package com.sonsofcrypto.web3walletcore.modules.qrCodeScan

import com.sonsofcrypto.web3lib.types.Network

interface QRCodeScanInteractor {
    fun validateAddress(address: String, network: Network): String?
}

class DefaultQRCodeScanInteractor: QRCodeScanInteractor {

    override fun validateAddress(address: String, network: Network): String? {
        // TODO: @Annon check this is ok. When scanning metamask we get back:
        // eg: "ethereum:0x887jui787dFF1500232E9E2De16d599329C6e65b"
        val updatedAddress = address.replace("${network.name.lowercase()}:", "")
        return if (network.isValidAddress(updatedAddress)) updatedAddress else null
    }
}

