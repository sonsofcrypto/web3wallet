package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WMnemonicSwitch(
    title: String,
    onOff: Boolean,
    modifier: Modifier = Modifier,
    onValueChange: (Boolean) -> Unit,
) {
    var value by remember { mutableStateOf(onOff) }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .then(modifier),
        verticalAlignment = Alignment.CenterVertically
    ) {
        W3WText(
            text = title,
            modifier = Modifier.weight(1f)
        )
        W3WSpacerHorizontal(theme().shapes.padding.half)
        W3WSwitch(
            checked = value,
            onCheckedChange = { value = it; onValueChange(value) }
        )
    }
}
