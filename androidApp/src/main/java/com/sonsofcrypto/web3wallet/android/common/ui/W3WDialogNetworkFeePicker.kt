package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.window.Dialog
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.annotatedStringCallout
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.extensions.Localized


@Composable
fun W3WDialogNetworkFeePicker(
    onDismissRequest: (() -> Unit),
    networkFees: List<NetworkFee>,
    networkFeeSelected: NetworkFee?,
    onNetworkFeeSelected: (NetworkFee) -> Unit,
) {
    Dialog(
        onDismissRequest = onDismissRequest,
    ) {
        W3WNavigationBar(
            Localized("alert.networkFeePicker.title"),
            preModifier = Modifier
                .clip(RoundedCornerShape(theme().shapes.cornerRadius))
        ) {
            Column(
                modifier = Modifier
                    .background(backgroundGradient())
                    .padding(theme().shapes.padding)
                    .fillMaxWidth()
            ) {
                networkFees.forEach { networkFee ->
                    NetworkFeeView(
                        networkFee = networkFee,
                        isSelected = networkFee == networkFeeSelected
                    ) {
                        onNetworkFeeSelected(networkFee)
                        onDismissRequest()
                    }
                }
            }
        }
    }
}

@Composable
private fun NetworkFeeView(
    networkFee: NetworkFee,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    val icon = if (isSelected) R.drawable.icon_check_box_24 else R.drawable.icon_check_box_empty_24
    Row(
        modifier = ModifierClickable(onClick = onClick)
            .fillMaxWidth()
            .height(theme().shapes.cellHeightSmall),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        W3WIcon(id = icon)
        W3WSpacerHorizontal(theme().shapes.padding.half)
        W3WText(
            text = networkFee.name,
            textAlign = TextAlign.Start,
            modifier = Modifier.weight(1f),
        )
        W3WSpacerHorizontal()
        val text = Formatters.currency.format(
            networkFee.amount,
            networkFee.currency,
            Formatters.Style.Custom(15u)
        ).annotatedStringCallout()
        W3WText(
            text = text,
            textAlign = TextAlign.End,
            modifier = Modifier.weight(1f),
        )
    }
}