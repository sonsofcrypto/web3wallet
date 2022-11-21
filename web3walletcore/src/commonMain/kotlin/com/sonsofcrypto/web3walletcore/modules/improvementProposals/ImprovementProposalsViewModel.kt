package com.sonsofcrypto.web3walletcore.modules.improvementProposals

import com.sonsofcrypto.web3walletcore.common.viewModels.ErrorViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.SectionHeaderViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal
import com.sonsofcrypto.web3walletcore.services.improvementProposals.ImprovementProposal.Category.*

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
        val error: ErrorViewModel
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

fun ImprovementProposal.Category.title(): String = when (this) {
    INTEGRATION -> Localized("proposals.infrastructure.title")
    INFRASTRUCTURE -> Localized("proposals.integration.title")
    FEATURE -> Localized("proposals.feature.title")
    UNKNOWN -> Localized("proposals.unknown.title")
} + " " + Localized("proposals")

fun ImprovementProposal.Category.description(): String = when (this) {
    INTEGRATION -> Localized("proposals.infrastructure.description")
    INFRASTRUCTURE -> Localized("proposals.integration.description")
    FEATURE -> Localized("proposals.feature.description")
    UNKNOWN -> ""
}
