package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.material.ContentAlpha
import androidx.compose.material.MaterialTheme
import androidx.compose.material.SwitchColors
import androidx.compose.material.SwitchDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.compositeOver
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WSwitchColors(): SwitchColors = SwitchDefaults.colors(
    checkedThumbColor = theme().colors.switchOnThumb,
    checkedTrackColor = theme().colors.switchOnTint,
    checkedTrackAlpha = 0.54f,
    uncheckedThumbColor = theme().colors.switchOffThumb,
    uncheckedTrackColor = theme().colors.switchOffTint,
    uncheckedTrackAlpha = 0.38f,
    disabledCheckedThumbColor = MaterialTheme.colors.secondaryVariant
        .copy(alpha = ContentAlpha.disabled)
        .compositeOver(MaterialTheme.colors.surface),
    disabledCheckedTrackColor = MaterialTheme.colors.secondaryVariant
        .copy(alpha = ContentAlpha.disabled)
        .compositeOver(MaterialTheme.colors.surface),
    disabledUncheckedThumbColor = MaterialTheme.colors.surface
        .copy(alpha = ContentAlpha.disabled)
        .compositeOver(MaterialTheme.colors.surface),
    disabledUncheckedTrackColor = MaterialTheme.colors.onSurface
        .copy(alpha = ContentAlpha.disabled)
        .compositeOver(MaterialTheme.colors.surface)
)
