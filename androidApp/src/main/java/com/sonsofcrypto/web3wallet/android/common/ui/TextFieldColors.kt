package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.material.LocalContentAlpha
import androidx.compose.material.MaterialTheme
import androidx.compose.material.TextFieldColors
import androidx.compose.material.TextFieldDefaults
import androidx.compose.runtime.Composable
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WTextFieldColors(): TextFieldColors = TextFieldDefaults.textFieldColors(
    textColor = theme().colors.textPrimary,
    backgroundColor = theme().colors.clear,
    unfocusedIndicatorColor = theme().colors.clear,
    disabledIndicatorColor = theme().colors.clear,
    disabledTextColor = theme().colors.textPrimary,
    focusedIndicatorColor = theme().colors.clear,
)
@Composable
fun W3WTextFieldColorsOutlined(): TextFieldColors = TextFieldDefaults.outlinedTextFieldColors(
    textColor = theme().colors.textPrimary,
    disabledTextColor = theme().colors.textPrimary,
    backgroundColor = theme().colors.clear,
    cursorColor = theme().colors.textPrimary,
    errorCursorColor = theme().colors.textFieldError,
    focusedBorderColor = theme().colors.textPrimary,
    unfocusedBorderColor = theme().colors.textSecondary,
    disabledBorderColor = theme().colors.textSecondary,
    errorBorderColor = theme().colors.textFieldError,
    leadingIconColor = theme().colors.textPrimary,
    disabledLeadingIconColor = theme().colors.textPrimary,
    errorLeadingIconColor = theme().colors.textFieldError,
    trailingIconColor = theme().colors.textPrimary,
    disabledTrailingIconColor = theme().colors.textPrimary,
    errorTrailingIconColor = theme().colors.textFieldError,
    focusedLabelColor = theme().colors.textPrimary,
    unfocusedLabelColor = theme().colors.textPrimary,
    disabledLabelColor = theme().colors.textPrimary,
    errorLabelColor = theme().colors.textFieldError,
    placeholderColor = theme().colors.textSecondary,
    disabledPlaceholderColor = theme().colors.textSecondary,
)
