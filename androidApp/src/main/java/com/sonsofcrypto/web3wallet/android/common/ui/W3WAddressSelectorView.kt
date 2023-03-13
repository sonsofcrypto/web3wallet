package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.TextField
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkAddressPickerViewModel

@Composable
fun W3WAddressSelectorView(
    viewModel: NetworkAddressPickerViewModel,
    value: TextFieldValue,
    onClear: (() -> Unit)? = null,
    onValueChanged: (TextFieldValue) -> Unit,
    onQRCodeClick: (() -> Unit) = {},
) {
    Row(
        modifier = ModifierCardBackground()
            .fillMaxWidth()
            .padding(start = theme().shapes.padding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Image(
            painter = painterResource(id = R.drawable.icon_qr_code_scanner_24),
            contentDescription = "qr code scanner",
            modifier = Modifier
                .size(24.dp)
                .then(ModifierClickable(onClick = onQRCodeClick))
        )
        TextField(
            value = value,
            onValueChange = onValueChanged,
            modifier = Modifier.weight(1f),
            textStyle = theme().fonts.title3,
            placeholder = {
                W3WText(
                    viewModel.placeholder,
                    color = theme().colors.textSecondary,
                    style = theme().fonts.title3
                )
            },
            singleLine = true,
            colors = W3WTextFieldColors(),
            trailingIcon = if (onClear != null) { { W3WClearIcon(onClear = onClear) } } else { null }
        )
    }
}