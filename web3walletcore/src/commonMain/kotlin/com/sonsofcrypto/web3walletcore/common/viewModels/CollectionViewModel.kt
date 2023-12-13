package com.sonsofcrypto.web3walletcore.common.viewModels

sealed class CollectionViewModel {

    data class Section(
        val header: Header? = null,
        val items: List<CellViewModel> = emptyList(),
        val footer: Footer? = null
    ): CollectionViewModel()

    data class Screen(
        val id: String,
        val sections: List<Section>,
        val rightBarButtons: List<BarButtonViewModel> = emptyList(),
        val ctaItems: List<ButtonViewModel> = emptyList(),
    ): CollectionViewModel()

    sealed class Header() {
        data class Title(
            val leading: String? = null,
            val trailing: String? = null
        ): Header()

        fun text(): String? = when (this) {
            is Title -> this.leading
        }
    }

    sealed class Footer() {
        data class Text(val text: String): Footer()
        data class HighlightWords(
            val text: String,
            val words: List<String>
        ): Footer()

        fun text(): String? = when (this) {
            is Text -> this.text
            is HighlightWords -> this.text
        }
    }
}


