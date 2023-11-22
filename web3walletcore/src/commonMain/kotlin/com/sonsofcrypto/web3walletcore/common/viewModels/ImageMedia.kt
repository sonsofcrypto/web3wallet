package com.sonsofcrypto.web3walletcore.common.viewModels

sealed class ImageMedia {
    data class Name(val name: String): ImageMedia()
    data class SysName(val name: String): ImageMedia()
    data class Url(val url: String): ImageMedia()
    data class Data(val data: ByteArray): ImageMedia()
}