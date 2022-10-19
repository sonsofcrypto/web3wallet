package com.sonsofcrypto.web3walletcore.common.viewModels

import com.sonsofcrypto.web3walletcore.extensions.Localized

data class ErrorViewModel(
    val title: String,
    val body: String,
    val actions: List<String>,
) { companion object }

fun ErrorViewModel.Companion.with(error: Throwable): ErrorViewModel {
    return ErrorViewModel(
        Localized("error"), error.toString(), listOf(Localized("OK"))
    )
}
