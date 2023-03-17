package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.SectionFooterViewModel

@Composable
fun SectionFooterViewModel.annotatedString(): AnnotatedString = buildAnnotatedString {
    append(text)
    addStyle(
        style = SpanStyle(
            color = theme().colors.textSecondary,
            fontSize = theme().fonts.subheadline.fontSize,
            fontStyle = theme().fonts.subheadline.fontStyle,
            fontWeight = theme().fonts.subheadline.fontWeight,
        ),
        start = 0,
        end = text.length,
    )
    highlightWords.forEach {
        val startIdx = text.indexOf(it)
        val endIdx = startIdx + it.length
        addStyle(
            style = SpanStyle(
                color = theme().colors.textPrimary,
                fontSize = theme().fonts.subheadline.fontSize,
                fontStyle = theme().fonts.subheadline.fontStyle,
                fontWeight = theme().fonts.subheadline.fontWeight,
            ),
            start = startIdx,
            end = endIdx,
        )
    }
}