package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import com.sonsofcrypto.web3wallet.android.common.decimals
import com.sonsofcrypto.web3wallet.android.common.nonDecimals
import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel

fun applyTextValidation(
    viewModel: CurrencyAmountPickerViewModel,
    old: String,
    value: String
): String {
    val totalOldDots = old.count { it == '.' || it == ',' }
    val totalNewDots = value.count { it == '.' || it == ',' }
    if ((value.decimals?.length?.toUInt() ?: 0u) > viewModel.maxDecimals) { return old }
    if (totalOldDots == 1 && totalNewDots == 2) { return old }
    if (viewModel.maxDecimals > 0u && (value == "." || value == ",")) { return "0." }
    if (old.startsWith("0.") && !value.startsWith("0.")) { return value.drop(1) }
    if (value.startsWith("0") && value.nonDecimals.count() > 1) { return value.drop(1) }
    if (totalNewDots > 1 && ( value.last() == '.' || value.last() == ',')) {
        return value.dropLast(1)
    }
    if (viewModel.maxDecimals == 0u && value == "0") { return "" }
    if (viewModel.maxDecimals == 0u && value == "00") { return "0.0" }
    if (value.any { it == ',' }) { return value.replace(',', '.') }
    return value.trim().replace("-", "")
}

/** This method updates the selection (TextRange) so the cursor is at the correct position
 *  since sometimes we modify the (newValue) string result of some validation. */
fun updateTextFieldValueSelection(
    value: TextFieldValue,
    newTextFieldValue: TextFieldValue,
    newValue: String,
): TextFieldValue =
    if (value.text.length + 2 == newValue.length) {
        TextFieldValue(newValue, TextRange(newValue.length))
    } else if (value.text == newValue && value.text != newTextFieldValue.text) {
        TextFieldValue(newValue, TextRange(value.selection.start))
    } else if (value.text.length == newValue.length && value.text != newValue) {
        TextFieldValue(newValue, TextRange(value.selection.start))
    } else {
        TextFieldValue(newValue, newTextFieldValue.selection)
    }
