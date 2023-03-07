package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.Dp
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun CardBackgroundModifier(
    cornerRadius: Dp = theme().shapes.cornerRadius
): Modifier = Modifier
    .clip(RoundedCornerShape(cornerRadius))
    .background(theme().colors.bgPrimary)

@Composable
fun ClickableModifier(onClick: () -> Unit): Modifier = Modifier.clickable(
        interactionSource = remember { MutableInteractionSource() },
        indication = null,
        onClick = onClick,
    )
