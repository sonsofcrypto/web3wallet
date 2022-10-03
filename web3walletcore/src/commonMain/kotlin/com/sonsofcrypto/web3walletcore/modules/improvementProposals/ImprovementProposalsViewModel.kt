package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.CommonErrorViewModel

sealed class ImprovementProposalsViewModel {
    /** Loading proposals */
    object Loading: ImprovementProposalsViewModel()
    /** Successfully fetched proposals */
    data class Loaded(
        val sections: List<Section>,
        val selectedIdx: Int
    ): ImprovementProposalsViewModel()
    /** Error occurred */
    data class Error(
        val error: CommonErrorViewModel
    ): ImprovementProposalsViewModel()

    data class Section(
        val title: String,
        val description: String,
        val items: List<Item>
    )

    data class Item(
        val id: String,
        val title: String,
        val subtitle: String,
        val btnTitle: String
    )
}
