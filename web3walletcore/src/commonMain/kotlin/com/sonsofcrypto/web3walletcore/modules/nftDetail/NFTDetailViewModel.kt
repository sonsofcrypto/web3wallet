package com.sonsofcrypto.web3walletcore.modules.nftDetail

data class NFTDetailViewModel(
    val imageURL: String,
    val fallBackImageURL: String?,
    val fallBackTest: String,
    val tokenID: String,
    val title: String,
    val infos: List<InfoGroup>
) {
    data class InfoGroup(
        val title: String,
        val items: List<Item>,
    ) {
        data class Item (
            val title: String?,
            val body: String?,
        )
    }
}