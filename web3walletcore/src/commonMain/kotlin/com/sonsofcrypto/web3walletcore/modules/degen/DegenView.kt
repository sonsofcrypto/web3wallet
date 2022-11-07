package com.sonsofcrypto.web3walletcore.modules.degen

interface DegenView {
    fun update(viewModel: DegenViewModel)
    fun popToRootAndRefresh()
}
