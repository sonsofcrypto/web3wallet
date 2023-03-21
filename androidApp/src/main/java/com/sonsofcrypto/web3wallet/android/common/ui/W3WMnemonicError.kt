package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.MnemonicWordInfo
import com.sonsofcrypto.web3walletcore.extensions.Localized


val List<MnemonicWordInfo>.invalidWords: List<MnemonicWordInfo> get() = filter { it.isInvalid }

@Composable
fun W3WMnemonicError(
    viewModel: List<MnemonicWordInfo>,
    isValid: Boolean,
): AnnotatedString? {
    val font = theme().fonts.subheadline
    viewModel.invalidWords.firstOrNull()?.let {wordInfo ->
        return buildAnnotatedString {
            withStyle(
                style = SpanStyle(
                    color = theme().colors.textFieldError,
                    fontSize = font.fontSize,
                    fontStyle = font.fontStyle,
                    fontWeight = font.fontWeight,
                )
            ) {
                append(wordInfo.word)
            }
            withStyle(
                style = SpanStyle(
                    color = theme().colors.textPrimary,
                    fontSize = font.fontSize,
                    fontStyle = font.fontStyle,
                    fontWeight = font.fontWeight,
                )
            ) {
                append(" ${Localized("mnemonic.invalid.word")}")
            }
        }
    }
    if (!isValid) {
        return buildAnnotatedString {
            withStyle(
                style = SpanStyle(
                    color = theme().colors.textFieldError,
                    fontSize = font.fontSize,
                    fontStyle = font.fontStyle,
                    fontWeight = font.fontWeight,
                )
            ) {
                append(" ${Localized("mnemonic.error.invalid")}")
            }
        }
    }
    return null
}
