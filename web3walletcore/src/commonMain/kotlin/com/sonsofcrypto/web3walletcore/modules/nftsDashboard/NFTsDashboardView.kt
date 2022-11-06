package com.sonsofcrypto.web3walletcore.modules.nftsDashboard

interface NFTsDashboardView {
    fun update(viewModel: NFTsDashboardViewModel)
    fun popToRootAndRefresh()
}