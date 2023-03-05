package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.material.TextField
import androidx.compose.material.TextFieldDefaults
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Clear
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel
import com.sonsofcrypto.web3walletcore.extensions.App
import com.sonsofcrypto.web3walletcore.extensions.Localized


@Composable
fun W3WCurrencyEditView(
    viewModel: CurrencyAmountPickerViewModel,
    value: TextFieldValue,
    onValueChanged: (TextFieldValue) -> Unit,
    onClear: () -> Unit,
    onCurrencyClick: () -> Unit,
    onMaxClick: (() -> Unit)? = null
) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(theme().shapes.cornerRadius))
            .background(theme().colors.bgPrimary)
            .padding(end = theme().shapes.padding)
            .fillMaxWidth(),
    ) {
        CurrencyEditTop(
            viewModel = viewModel,
            value = value,
            onValueChanged = onValueChanged,
            onClear = onClear,
            onCurrencyClick = onCurrencyClick,
            enabled = true
        )
        CurrencyFiatView(viewModel = viewModel, onMaxClick = onMaxClick)
    }
}

@Composable
fun W3WCurrencyView(
    viewModel: CurrencyAmountPickerViewModel,
    onCurrencyClick: () -> Unit,
) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(theme().shapes.cornerRadius))
            .background(theme().colors.bgPrimary)
            .padding(end = theme().shapes.padding)
            .fillMaxWidth(),
    ) {
        CurrencyEditTop(
            viewModel = viewModel,
            value = TextFieldValue(viewModel.amount?.string(viewModel.maxDecimals) ?: "0"),
            onCurrencyClick = onCurrencyClick,
            enabled = false
        )
        CurrencyFiatView(viewModel = viewModel)
    }
}

@Composable
private fun CurrencyEditTop(
    viewModel: CurrencyAmountPickerViewModel,
    value: TextFieldValue,
    onValueChanged: (TextFieldValue) -> Unit = {},
    onClear: (() -> Unit)? = null,
    onCurrencyClick: () -> Unit,
    enabled: Boolean,
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
    ) {
        TextField(
            value = value,
            onValueChange = onValueChanged,
            modifier = Modifier.weight(1f),
            enabled = enabled,
            textStyle = theme().fonts.title3,
            placeholder = {
                W3WText("0", color = theme().colors.textSecondary, style = theme().fonts.title3)
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            singleLine = true,
            colors = TextFieldDefaults.textFieldColors(
                textColor = theme().colors.textPrimary,
                backgroundColor = theme().colors.clear,
                unfocusedIndicatorColor = theme().colors.clear,
                disabledIndicatorColor = theme().colors.clear,
                disabledTextColor = theme().colors.textPrimary,
                focusedIndicatorColor = theme().colors.clear,
            ),
            trailingIcon = if (onClear != null) {
                { CurrencyEditClearAction(onClear) }
            } else { null }
        )
        CurrencyPickerView(viewModel, onCurrencyClick)
    }
}

@Composable
private fun CurrencyEditClearAction(onClear: () -> Unit) {
    Icon(
        Icons.Default.Clear,
        contentDescription = "clear text",
        modifier = Modifier
            .clickable { onClear() }
            .size(24.dp),
        tint = theme().colors.textSecondary,
    )
}

@Composable
private fun CurrencyFiatView(
    viewModel: CurrencyAmountPickerViewModel,
    onMaxClick: (() -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = theme().shapes.padding,
                bottom = theme().shapes.padding,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        W3WText(
            text = fiatPrice(
                viewModel,
                normalTextStyle = theme().fonts.callout,
                smallTextStyle = theme().fonts.caption2,
            ),
            style = theme().fonts.callout,
            modifier = Modifier.weight(1f),
            textAlign = TextAlign.Start,
        )
        W3WSpacerHorizontal(theme().shapes.padding)
        W3WText(
            text = balance(
                viewModel,
                normalTextStyle = theme().fonts.callout,
                smallTextStyle = theme().fonts.caption2,
            ),
            style = theme().fonts.subheadline,
            modifier = Modifier.weight(1f),
            textAlign = TextAlign.End,
        )
        onMaxClick?.let { onClick ->
            W3WSpacerHorizontal(theme().shapes.padding.half)
            var size by remember { mutableStateOf(IntSize.Zero) }
            Box(
                modifier = Modifier
                    .onSizeChanged { size = it }
                    .width(44.dp)
                    .height(24.dp)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = onClick,
                    )
                    .border(
                        width = 0.5.dp,
                        color = theme().colors.textPrimary,
                        shape = RoundedCornerShape(size.height.dp.half)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    Localized("max").uppercase(),
                    color = theme().colors.buttonTextSecondary,
                    style = theme().fonts.footnote,
                )
            }
        }
    }
}

private fun fiatPrice(
    viewModel: CurrencyAmountPickerViewModel,
    normalTextStyle: TextStyle,
    smallTextStyle: TextStyle,
): AnnotatedString {
    val amount = viewModel.amount ?: BigInt.zero
    val value = Formatters.crypto(amount, viewModel.maxDecimals, viewModel.fiatPrice)
    return Formatters.fiat.format(
        BigDec.from(value),
        style = Formatters.Style.Custom(12u)
    ).annotatedString(
        spanStylePrefix = SpanStyle(
            fontSize = normalTextStyle.fontSize,
            baselineShift = BaselineShift(-0.2f),
        ),
        spanStyleNormal = SpanStyle(
            fontSize = normalTextStyle.fontSize,
            baselineShift = BaselineShift(-0.2f),
        ),
        spanStyleUp = SpanStyle(
            fontSize = smallTextStyle.fontSize,
            baselineShift = BaselineShift(0.3f),
        ),
        spanStyleDown = SpanStyle(
            fontSize = smallTextStyle.fontSize,
            baselineShift = BaselineShift(-0.5f),
        ),
    )
}

private fun balance(
    viewModel: CurrencyAmountPickerViewModel,
    normalTextStyle: TextStyle,
    smallTextStyle: TextStyle,
): AnnotatedString = Formatters.currency.format(
    viewModel.maxAmount,
    viewModel.currency,
    Formatters.Style.Custom(12u),
    addCurrencySymbol = false,
).annotatedString(
    prefix = Localized("balance").plus(": "),
    spanStylePrefix = SpanStyle(
        fontSize = normalTextStyle.fontSize,
        baselineShift = BaselineShift(-0.2f),
    ),
    spanStyleNormal = SpanStyle(
        fontSize = normalTextStyle.fontSize,
        baselineShift = BaselineShift(-0.2f),
    ),
    spanStyleUp = SpanStyle(
        fontSize = smallTextStyle.fontSize,
        baselineShift = BaselineShift(0.3f),
    ),
    spanStyleDown = SpanStyle(
        fontSize = smallTextStyle.fontSize,
        baselineShift = BaselineShift(-0.5f),
    ),
)

@Composable
private fun CurrencyPickerView(viewModel: CurrencyAmountPickerViewModel, onClick: () -> Unit) {
    var size by remember { mutableStateOf(IntSize.Zero) }
    Row(
        modifier = Modifier
            .onSizeChanged { size = it }
            .wrapContentWidth()
            .clip(RoundedCornerShape(size.height.dp.half))
            .background(theme().colors.bgPrimary)
            .padding(
                start = theme().shapes.padding.half.threeQuarter,
                top = theme().shapes.padding.half.threeQuarter,
                bottom = theme().shapes.padding.half.threeQuarter,
            )
            .clickable { onClick() },
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Image(
            painter = painterResource(
                id = App.activity.drawableResource(viewModel.symbolIconName)
            ),
            contentDescription = "currency from ${viewModel.symbolIconName}",
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
        )
        W3WSpacerHorizontal(theme().shapes.padding.half.threeQuarter)
        W3WText(
            text = viewModel.symbol,
            textAlign = TextAlign.Center,
        )
        Icon(
            Icons.Default.ArrowDropDown,
            contentDescription = "drop down",
            tint = theme().colors.textPrimary,
        )
    }
}