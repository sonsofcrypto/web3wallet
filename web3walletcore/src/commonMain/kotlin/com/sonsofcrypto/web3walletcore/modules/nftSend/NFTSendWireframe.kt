package com.sonsofcrypto.web3walletcore.modules.nftSend

import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframeContext.SendNFT
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

data class NFTSendWireframeContext(
    val network: Network,
    val nftItem: NFTItem,
)

sealed class NFTSendWireframeDestination {
    object UnderConstructionAlert: NFTSendWireframeDestination()
    data class QRCodeScan(val onCompletion: (String) -> Unit): NFTSendWireframeDestination()
    data class ConfirmSendNFT(val context: SendNFT): NFTSendWireframeDestination()
    object Dismiss: NFTSendWireframeDestination()
}

interface NFTSendWireframe {
    fun present()
    fun navigate(destination: NFTSendWireframeDestination)
}
