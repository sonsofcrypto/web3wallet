package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.modifier.modifierLocalConsumer
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.KeyboardType.Companion.NumberPassword
import androidx.compose.ui.text.input.KeyboardType.Companion.Password
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3wallet.android.common.extensions.double
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.SegmentWithTextAndSwitchCellViewModel

@Composable
fun W3WMnemonicSegmentTexAndSwitch(
    viewModel: SegmentWithTextAndSwitchCellViewModel,
    modifier: Modifier,
    onSegmentChange: (Int) -> Unit,
    onPasswordChange: (String) -> Unit,
    onAllowFaceIDChange: (Boolean) -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .then(modifier)
            .padding(
                top = theme().shapes.padding,
                bottom = theme().shapes.padding,
            )
    ) {
        W3WMnemonicSegmentRow(
            title = viewModel.title,
            segmentOptions = viewModel.segmentOptions,
            selectedSegment = viewModel.selectedSegment,
            onSegmentChange = onSegmentChange,
        )
        when (viewModel.selectedSegment) {
            0 -> {
                W3WMnemonicPasswordEntry(
                    viewModel = viewModel,
                    onPasswordChange = onPasswordChange,
                    keyboardOptions = KeyboardOptions(keyboardType = NumberPassword)
                )
                W3WMnemonicError(viewModel.errorMessage)
                W3WMnemonicSwitch(
                    title = viewModel.onOffTitle,
                    onOff = viewModel.onOff,
                    modifier = Modifier.padding(
                        top = theme().shapes.padding.half.half,
                        start = theme().shapes.padding,
                        end = theme().shapes.padding,
                    ),
                    onValueChange = onAllowFaceIDChange
                )
            }
            1 -> {
                W3WMnemonicPasswordEntry(
                    viewModel = viewModel,
                    onPasswordChange = onPasswordChange,
                    keyboardOptions = KeyboardOptions(keyboardType = Password)
                )
                W3WMnemonicError(viewModel.errorMessage)
                W3WMnemonicSwitch(
                    title = viewModel.onOffTitle,
                    onOff = viewModel.onOff,
                    modifier = Modifier.padding(
                        top = theme().shapes.padding.half.half,
                        start = theme().shapes.padding,
                        end = theme().shapes.padding,
                    ),
                    onValueChange = onAllowFaceIDChange
                )
            }
        }
    }
}

@Composable
private fun W3WMnemonicError(error: String?) {
    error?.let {
        W3WText(
            text = it,
            color = theme().colors.textFieldError,
            modifier = Modifier.padding(
                start = theme().shapes.padding,
                end = theme().shapes.padding,
            ),
            style = theme().fonts.caption2
        )
        W3WSpacerVertical(theme().shapes.padding.half)
    }
}

@Composable
private fun W3WMnemonicSegmentRow(
    title: String,
    segmentOptions: List<String>,
    selectedSegment: Int,
    onSegmentChange: (Int) -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = theme().shapes.padding,
                end = theme().shapes.padding,
            )
    ) {
        W3WText(text = title)
        W3WSpacerHorizontal(theme().shapes.padding.double.double)
        W3WMnemonicSegmentControl(
            segmentOptions = segmentOptions,
            selectedSegment = selectedSegment,
            onSegmentChange = onSegmentChange
        )
    }
}

@Composable
private fun RowScope.W3WMnemonicSegmentControl(
    segmentOptions: List<String>,
    selectedSegment: Int,
    onSegmentChange: (Int) -> Unit,
) {
    Row(
        modifier = Modifier
            .weight(1f)
            .height(30.dp)
            .clip(RoundedCornerShape(4.dp))
            .background(theme().colors.segmentedControlBackground),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        var segment by remember { mutableStateOf(segmentOptions[selectedSegment]) }
        val selectedSegment = segmentOptions[selectedSegment]
        segmentOptions.forEach {
            W3WMnemonicSegmentOption(
                title = it,
                isSelected = it == selectedSegment,
                onClick = { segment = it; onSegmentChange(segmentOptions.indexOf(it)) }
            )
        }
    }
}

@Composable
private fun RowScope.W3WMnemonicSegmentOption(
    title: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val bgColor = theme().colors.segmentedControlBackground
    val bgSelectedColor = theme().colors.segmentedControlBackgroundSelected
    val textColor = theme().colors.segmentedControlText
    val textSelectedColor = theme().colors.segmentedControlTextSelected
    W3WText(
        text = title,
        modifier = ModifierClickable(onClick = onClick)
            .weight(1f)
            .fillMaxHeight()
            .background(if (isSelected) bgSelectedColor else bgColor)
            .padding(start = 8.dp, top = 4.dp, end = 8.dp),
        color = if (isSelected) textSelectedColor else textColor,
        style = theme().fonts.footnote,
        textAlign = TextAlign.Center,
    )
}

@Composable
private fun W3WMnemonicPasswordEntry(
    viewModel: SegmentWithTextAndSwitchCellViewModel,
    onPasswordChange: (String) -> Unit,
    keyboardOptions: KeyboardOptions,
) {
    W3WMnemonicTextInput(
        value = viewModel.password,
        placeholder = viewModel.placeholder,
        onValueChange = onPasswordChange,
        keyboardOptions = keyboardOptions,
    )
}
