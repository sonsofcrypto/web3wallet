package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.withStyle
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3wallet.android.common.theme

fun List<Formatters.Output>.add(
    value: Formatters.Output,
): List<Formatters.Output> {
    var list = this.toMutableList()
    list.add(value)
    return list
}

fun List<Formatters.Output>.addAll(
    elements: List<Formatters.Output>,
): List<Formatters.Output> {
    var list = this.toMutableList()
    list.addAll(elements)
    return list
}

fun List<Formatters.Output>.annotatedString(
    prefix: String? = null,
    spanStylePrefix: SpanStyle? = null,
    spanStyleNormal: SpanStyle,
    spanStyleUp: SpanStyle,
    spanStyleDown: SpanStyle,
): AnnotatedString {
    return buildAnnotatedString {
        prefix?.let { prefix ->
            spanStylePrefix?.let { withStyle(it) { append(prefix) } }
        }
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

@Composable
fun List<Formatters.Output>.annotatedStringCallout(): AnnotatedString = annotatedString(
    spanStylePrefix = SpanStyle(
        fontSize = theme().fonts.callout.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleNormal = SpanStyle(
        fontSize = theme().fonts.callout.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(0.5f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(-0.3f),
    ),
)

@Composable
fun List<Formatters.Output>.annotatedStringFootnote(): AnnotatedString = annotatedString(
    spanStyleNormal = SpanStyle(
        fontSize = theme().fonts.footnote.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = theme().fonts.extraSmall.fontSize,
        baselineShift = BaselineShift(0.5f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = theme().fonts.extraSmall.fontSize,
        baselineShift = BaselineShift(-0.3f),
    ),
)

@Composable
fun List<Formatters.Output>.annotatedStringSubheadline(): AnnotatedString = annotatedString(
    spanStyleNormal = SpanStyle(
        fontSize = theme().fonts.subheadline.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(0.5f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(-0.3f),
    ),
)

@Composable
fun List<Formatters.Output>.annotatedStringBody(): AnnotatedString = annotatedString(
    spanStyleNormal = SpanStyle(
        fontSize = theme().fonts.body.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(0.5f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = theme().fonts.caption2.fontSize,
        baselineShift = BaselineShift(-0.3f),
    ),
)

@Composable
fun List<Formatters.Output>.annotatedStringLargeTitle(): AnnotatedString = annotatedString(
    spanStylePrefix = SpanStyle(
        fontSize = theme().fonts.largeTitleBold.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleNormal = SpanStyle(
        fontSize = theme().fonts.largeTitleBold.fontSize,
        baselineShift = BaselineShift(0f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = theme().fonts.headlineBold.fontSize,
        baselineShift = BaselineShift(0.7f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = theme().fonts.headlineBold.fontSize,
        baselineShift = BaselineShift(-0.5f),
    ),
)

