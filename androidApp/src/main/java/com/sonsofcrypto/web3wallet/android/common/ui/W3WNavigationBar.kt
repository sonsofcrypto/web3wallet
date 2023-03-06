package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.sonsofcrypto.web3wallet.android.common.theme

@Composable
fun W3WNavigationBar(
    title: String,
    preModifier: Modifier = Modifier,
    modifier: Modifier = Modifier,
    content: @Composable (() -> Unit)? = null,
) {
    Column(
        modifier =
        preModifier.then(
            Modifier
                .background(theme().colors.navBarBackground)
                .fillMaxWidth()
        ).then(modifier),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(modifier = Modifier.height(theme().shapes.padding))
        Text(
            title,
            color = theme().colors.navBarTitle,
            style = theme().fonts.navTitle,
        )
        Spacer(modifier = Modifier.height(theme().shapes.padding))
        content?.let { it() }
    }
}