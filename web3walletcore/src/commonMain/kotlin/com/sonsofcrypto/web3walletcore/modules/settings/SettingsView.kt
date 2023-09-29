package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel

interface SettingsView {
    fun update(viewModel: CollectionViewModel.Screen)
}