package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material.ProgressIndicatorDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.unit.Dp
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WLoadingInMaxSizeContainer() {
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            W3WLoading()
        }
    }
}

@Composable
fun W3WLoading(
    modifier: Modifier = Modifier,
    color: Color = theme().colors.textPrimary,
    strokeWidth: Dp = ProgressIndicatorDefaults.StrokeWidth,
    backgroundColor: Color = Color.Transparent,
    strokeCap: StrokeCap = StrokeCap.Square,
) {
    CircularProgressIndicator(
        modifier,
        color,
        strokeWidth,
        backgroundColor,
        strokeCap,
    )
}
