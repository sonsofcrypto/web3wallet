package com.sonsofcrypto.web3walletcore.common.viewModels

sealed class CellViewModel {
    enum class Accessory {
        NONE, DETAIL, CHECKMARK
    }
    data class Label(
        val text: String,
        val accessory: Accessory = Accessory.NONE
    ): CellViewModel()


}