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
fun W3WUnderConstructionAlert(onDismissRequest: (() -> Unit)) {
    Dialog(
        onDismissRequest = onDismissRequest,
    ) {
        W3WNavigationBar(
            Localized("alert.underConstruction.title"),
            preModifier = Modifier
                .clip(RoundedCornerShape(theme().shapes.cornerRadius))
        ) {

            Column(
                modifier = Modifier
                    .background(backgroundGradient())
                    .padding(theme().shapes.padding)
                    .fillMaxWidth()
            ) {
                W3WGifImage(
                    R.drawable.under_construction,
                    modifier = Modifier.height(300.dp)
                )
                W3WSpacerVertical()
                W3WText(
                    Localized("alert.underConstruction.message"),
                    textAlign = TextAlign.Center,
                )
                W3WSpacerVertical()
                W3WButtonPrimary(
                    title = Localized("OK"),
                    onClick = onDismissRequest
                )
            }
        }
    }
}
