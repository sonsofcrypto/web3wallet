package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import com.sonsofcrypto.web3lib.formatters.Formatters

fun List<Formatters.Output>.annotatedString(
    prefix: String? = null,
    spanStylePrefix: SpanStyle,
    spanStyleNormal: SpanStyle,
    spanStyleUp: SpanStyle,
    spanStyleDown: SpanStyle,
): AnnotatedString {
    return buildAnnotatedString {
        prefix?.let { prefix -> withStyle(spanStylePrefix) { append(prefix) } }
        forEach {
            when (it) {
                is Formatters.Output.Normal -> {
                    withStyle(spanStyleNormal) { append(it.value) }
                }
                is Formatters.Output.Up -> {
                    withStyle(spanStyleUp) { append(it.value) }
                }
                is Formatters.Output.Down -> {
                    withStyle(spanStyleDown) { append(it.value) }
                }
            }
        }
    }
}
