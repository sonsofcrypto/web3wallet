package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier

@Composable
fun W3WScreen(
    navBar: @Composable (() -> Unit)? = null,
    content: @Composable (() -> Unit),
) {
    Column(
        modifier = Modifier
            .background(backgroundGradient())
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        navBar?.let { it() }
        content()
    }
}
