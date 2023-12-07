package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.Tint.NORMAL

sealed class ImageMedia {
    data class Name(val name: String): ImageMedia()
    data class SysName(val name: String, val tint: Tint = NORMAL): ImageMedia()
    data class Url(val url: String): ImageMedia()
    data class Data(val data: ByteArray): ImageMedia()

    enum class Tint {
        NORMAL, DESTRUCTIVE
    }
}