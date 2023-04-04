package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.Indication
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.MnemonicWordInfo

@Composable
fun ModifierCardBackground(
    cornerRadius: Dp = theme().shapes.cornerRadius
): Modifier = Modifier
    .clip(RoundedCornerShape(cornerRadius))
    .background(theme().colors.bgPrimary)

@Composable
fun ModifierBorder(
    width: Dp = 1.dp,
    color: Color = theme().colors.textPrimary,
    cornerRadius: Dp = theme().shapes.cornerRadius
): Modifier = Modifier
    .border(
        width = width,
        color = color,
        shape = RoundedCornerShape(cornerRadius)
    )

@Composable
fun ModifierClickable(
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() },
    indication: Indication? = null,
    enabled: Boolean = true,
    onClick: () -> Unit,
): Modifier = Modifier.clickable(
    interactionSource = interactionSource,
    indication = indication,
    enabled = enabled,
    onClick = onClick,
)

@Composable
fun ModifierDynamicBg(idx: Int, total: Int): Modifier {
    return if (total == 1) {
        Modifier
            .clip(RoundedCornerShape(theme().shapes.cornerRadius))
            .background(theme().colors.bgPrimary)
    } else if (idx == 0) {
        Modifier
            .clip(
                RoundedCornerShape(
                    topStart = theme().shapes.cornerRadius,
                    topEnd = theme().shapes.cornerRadius,
                )
            )
            .background(theme().colors.bgPrimary)
    } else if (idx == total - 1) {
        Modifier
            .clip(
                RoundedCornerShape(
                    bottomStart = theme().shapes.cornerRadius,
                    bottomEnd = theme().shapes.cornerRadius,
                )
            )
            .background(theme().colors.bgPrimary)
    } else {
        Modifier.background(theme().colors.bgPrimary)
    }
}

@Composable
fun ModifierMnemonicValidationBorder(
    wordsInfo: List<MnemonicWordInfo>,
    isValid: Boolean?
): Modifier {
    val modifierInvalid = ModifierBorder(width = 2.dp, color = theme().colors.textFieldError)
    if (wordsInfo.invalidWords.isNotEmpty()) { return modifierInvalid }
    if (isValid == false) { return modifierInvalid }
    return Modifier
}
