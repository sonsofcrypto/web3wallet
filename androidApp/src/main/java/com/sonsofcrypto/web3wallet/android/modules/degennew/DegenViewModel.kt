package com.sonsofcrypto.web3wallet.android.modules.degennew

data class DegenNewViewModel(
    val sections: List<Section>
) {
    data class Item(
        val title: String,
        val subtitle: String
    )

    data class Section(
        val title: String,
        val items: List<Item>
    )
}

fun mock(): DegenNewViewModel = DegenNewViewModel(
    listOf(
        DegenNewViewModel.Section(
            "Section 0",
            listOf(
                DegenNewViewModel.Item("zero", "mock zero"),
                DegenNewViewModel.Item("one", "mock one"),
                DegenNewViewModel.Item("two", "mock two"),
                DegenNewViewModel.Item("three", "mock three"),
            )
        ),
        DegenNewViewModel.Section(
            "Section 1",
            listOf(
                DegenNewViewModel.Item("zero", "mock zero"),
                DegenNewViewModel.Item("one", "mock one"),
                DegenNewViewModel.Item("two", "mock two"),
                DegenNewViewModel.Item("three", "mock three"),
                DegenNewViewModel.Item("four", "mock four"),
            )
        )
    )
)
