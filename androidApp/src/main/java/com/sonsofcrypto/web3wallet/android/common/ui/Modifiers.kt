package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
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