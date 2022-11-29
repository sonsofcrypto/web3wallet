package com.sonsofcrypto.web3walletcore.modules.dashboard

import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

sealed class DashboardWireframeDestination {
    data class Wallet(val network: Network, val currency: Currency): DashboardWireframeDestination()
    object KeyStoreNetworkSettings: DashboardWireframeDestination()
    object PresentUnderConstructionAlert: DashboardWireframeDestination()
    object ScanQRCode: DashboardWireframeDestination()
    object MnemonicConfirmation: DashboardWireframeDestination()
    object ThemePicker: DashboardWireframeDestination()
    object ImprovementProposals: DashboardWireframeDestination()
    object Receive: DashboardWireframeDestination()
    data class Send(val addressTo: String?): DashboardWireframeDestination()
    object Swap: DashboardWireframeDestination()
    data class EditCurrencies(
        val network: Network,
        val selectedCurrencies: List<Currency>,
        val onCompletion: (List<Currency>) -> Unit
    ): DashboardWireframeDestination()
    data class NftItem(val nft: NFTItem): DashboardWireframeDestination()
    data class DeepLink(val deepLink: DeepLink): DashboardWireframeDestination()
}

interface DashboardWireframe {
    fun present()
    fun navigate(destination: DashboardWireframeDestination)
}