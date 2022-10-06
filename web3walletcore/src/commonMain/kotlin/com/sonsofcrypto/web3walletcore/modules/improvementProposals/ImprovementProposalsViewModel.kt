package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.CommonErrorViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal
import com.sonsofcrypto.web3walletcore.services.ImprovmentProposals.ImprovementProposal.Category.*

sealed class ImprovementProposalsViewModel {
    /** Loading proposals */
    object Loading: ImprovementProposalsViewModel()
    /** Successfully fetched proposals */
    data class Loaded(
        val categories: List<Category>,
        val selectedIdx: Int
    ): ImprovementProposalsViewModel()
    /** Error occurred */
    data class Error(
        val error: CommonErrorViewModel
    ): ImprovementProposalsViewModel()

    data class Category(
        val title: String,
        val description: String,
        val items: List<Item>
    )

    data class Item(
        val id: String,
        val title: String,
        val subtitle: String,
    )

    fun selectedCategory(): Category? = when (this) {
        is Loaded -> if(categories.isNotEmpty()) categories[selectedIdx] else null
        else -> null
    }

    companion object
}

fun ImprovementProposalsViewModel.Companion.title(
    category: ImprovementProposal.Category
): String = when (category) {
    INTEGRATION -> Localized("proposals.infrastructure.title")
    INFRASTRUCTURE -> Localized("proposals.integration.title")
    FEATURE -> Localized("proposals.feature.title")
    UNKNOWN -> Localized("proposals.unknown.title")
} + " " + Localized("proposals")

fun ImprovementProposalsViewModel.Companion.description(
    category: ImprovementProposal.Category
): String = when (category) {
    INTEGRATION -> Localized("proposals.infrastructure.description")
    INFRASTRUCTURE -> Localized("proposals.integration.description")
    FEATURE -> Localized("proposals.feature.description")
    UNKNOWN -> ""
}
