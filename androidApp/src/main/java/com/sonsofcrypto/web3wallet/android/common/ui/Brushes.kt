package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun backgroundGradient(): Brush {
    return Brush.verticalGradient(
        listOf(theme().colors.bgGradientTop, theme().colors.bgGradientBtm)
    )
}