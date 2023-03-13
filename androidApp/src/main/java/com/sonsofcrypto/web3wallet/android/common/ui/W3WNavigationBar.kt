package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WNavigationBar(
    title: String,
    leadingIcon: @Composable (() -> Unit)? = null,
    trailingIcon: @Composable (() -> Unit)? = null,
    preModifier: Modifier = Modifier,
    modifier: Modifier = Modifier,
    content: @Composable (() -> Unit)? = null,
) {
    Column(
        modifier = preModifier
            .then(
                Modifier
                    .background(theme().colors.navBarBackground)
                    .fillMaxWidth()
            )
            .then(modifier),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Row(
            modifier = Modifier.padding(theme().shapes.padding)
        ) {
            leadingIcon?.let { it() }
            W3WText(
                title,
                textAlign = TextAlign.Center,
                modifier = Modifier.weight(1f),
                color = theme().colors.navBarTitle,
                style = theme().fonts.navTitle,
            )
            trailingIcon?.let { it() }
        }
        content?.let { it() }
    }
}