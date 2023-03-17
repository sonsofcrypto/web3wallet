package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3wallet.android.common.extensions.double
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WMnemonicTextInput(
    title: String? = null,
    value: String,
    placeholder: String,
    modifier: Modifier = Modifier,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    onValueChange: (String) -> Unit,
) {
    var value by remember { mutableStateOf(value) }
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically
    ) {
        title?.let {
            W3WText(text = title)
            W3WSpacerHorizontal(theme().shapes.padding.double)
        }
        W3WTextField(
            value = value,
            onValueChange = { value = it; onValueChange(value) },
            modifier = Modifier
                .weight(1f)
                .height(30.dp),
            keyboardOptions = keyboardOptions,
            placeholder = {
                W3WText(placeholder, color = theme().colors.textSecondary)
            },
            trailingIcon = if (value.isEmpty()) null
            else {
                { W3WClearIcon { value = ""; onValueChange(value) } }
            }
        )
    }
}
