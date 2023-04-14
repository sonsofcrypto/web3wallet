package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.unit.dp
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.firstLetterCapital
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized

@Composable
fun W3WNetworkFeeRowView(
    viewModel: NetworkFeeViewModel,
    onClick: () -> Unit,
) {
    Row(
        modifier = Modifier
            .padding(start = theme().shapes.padding, end = theme().shapes.padding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        W3WText(
            text = Localized("networkFeeView.estimatedFee"),
            style = theme().fonts.footnote,
            modifier = Modifier.weight(1.0f),
        )
        val amount = viewModel.amount
            .add(Formatters.Output.Normal(" - "))
            .addAll(viewModel.time)
            .annotatedStringFootnoteNetworkFee()
        W3WText(text = amount)
        W3WSpacerHorizontal(theme().shapes.padding.half)
        W3WButtonSecondarySmall(
            title = viewModel.name.firstLetterCapital,
            onClick = onClick,
        )
    }
}