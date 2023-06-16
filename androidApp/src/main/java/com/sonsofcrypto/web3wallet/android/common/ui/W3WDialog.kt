package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.extensions.Localized

@Composable
fun W3WDialog(
    title: String?,
    media: @Composable (() -> Unit)? = null,
    message: String?,
    actions: @Composable (() -> Unit),
    onDismissRequest: (() -> Unit)
) {
    Dialog(
        onDismissRequest = onDismissRequest,
    ) {
        W3WNavigationBar(
            title ?: "",
            preModifier = Modifier
                .clip(RoundedCornerShape(theme().shapes.cornerRadius))
        ) {
            Column(
                modifier = Modifier
                    .background(backgroundGradient())
                    .padding(theme().shapes.padding)
                    .fillMaxWidth()
            ) {
                media?.let {
                    media()
                    W3WSpacerVertical()
                }
                W3WText(
                    message ?: "",
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center,
                )
                W3WSpacerVertical()
                actions()
            }
        }
    }
}

@Composable
fun W3WDialogUnderConstruction(onDismissRequest: (() -> Unit)) {
    W3WDialog(
        title = Localized("alert.underConstruction.title"),
        media = {
            W3WGifImage(
                R.drawable.under_construction,
                modifier = Modifier.height(300.dp)
            )
        },
        message = Localized("alert.underConstruction.message"),
        actions = {
            W3WButtonPrimary(
                title = Localized("OK"),
                onClick = onDismissRequest
            )
        },
        onDismissRequest = onDismissRequest
    )
}

