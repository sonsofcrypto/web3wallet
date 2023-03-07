package com.sonsofcrypto.web3wallet.android.common.ui

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