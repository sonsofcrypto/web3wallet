package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.extensions.Localized

data class CommonErrorViewModel(
    val title: String,
    val body: String,
    val actions: List<String>,
) { companion object }

fun CommonErrorViewModel.Companion.with(error: Throwable): CommonErrorViewModel {
    return CommonErrorViewModel(
        Localized("error"), error.toString(), listOf(Localized("OK"))
    )
}