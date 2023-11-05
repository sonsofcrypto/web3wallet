package com.sonsofcrypto.web3walletcore.modules.mnemonicImport

import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicInputViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel

interface MnemonicImportView {
    fun update(
        viewModel: CollectionViewModel.Screen,
        mnemonicInputViewModel: MnemonicInputViewModel
    )
}
