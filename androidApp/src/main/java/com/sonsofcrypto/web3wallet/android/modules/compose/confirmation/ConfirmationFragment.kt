package com.sonsofcrypto.web3wallet.android.modules.compose.confirmation

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.confirmation.*
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationPresenterEvent.*

class ConfirmationFragment: Fragment(), ConfirmationView {

    lateinit var presenter: ConfirmationPresenter
    private val liveData = MutableLiveData<ConfirmationViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { ConfirmationScreen(it) }
            }
        }
    }

    override fun update(viewModel: ConfirmationViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun ConfirmationScreen(viewModel: ConfirmationViewModel) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.55f))
                .then(ModifierClickable { presenter.handle(Dismiss) }),
            contentAlignment = Alignment.BottomCenter
        ) {
            ConfirmationBottomSheet(viewModel)
        }
    }

    @Composable
    private fun ConfirmationBottomSheet(viewModel: ConfirmationViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .clip(RoundedCornerShape(theme().shapes.cornerRadius))
                .background(backgroundGradient()),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WNavigationBar(
                title = viewModel.title,
                trailingIcon = { W3WNavigationClose { presenter.handle(Dismiss) } }
            )
            ConfirmationContent(viewModel)
        }
    }

    @Composable
    private fun ConfirmationContent(viewModel: ConfirmationViewModel) {
        when (val content = viewModel.content) {
            is ConfirmationViewModel.Content.TxInProgress -> {
                ConfirmationContentTxInProgress(content.data)
            }
            is ConfirmationViewModel.Content.TxSuccess -> {
                ConfirmationContentTxSuccess(content.data)
            }
            is ConfirmationViewModel.Content.TxFailed -> {
                ConfirmationContentTxFailed(content.data)
            }
            is ConfirmationViewModel.Content.SendNFT -> {
                ConfirmationContentSendNFT(content.data)
            }
            is ConfirmationViewModel.Content.Send -> {
                ConfirmationContentSend(content.data)
            }
            is ConfirmationViewModel.Content.Swap -> {
                ConfirmationContentSwap(content.data)
            }
            is ConfirmationViewModel.Content.ApproveUniswap -> {
                ConfirmationContentApproveUniswap(content.data)
            }
            is ConfirmationViewModel.Content.CultCastVote -> {
                ConfirmationContentCultCastVote(content.data)
            }
        }
    }

    @Composable
    private fun ConfirmationContentTxInProgress(viewModel: ConfirmationTxInProgressViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth()
                .height(250.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WLoading()
            W3WSpacerVertical()
            W3WText(
                text = viewModel.title,
                textAlign = TextAlign.Center,
                style = theme().fonts.title3,
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.message,
                textAlign = TextAlign.Center,
            )
        }
    }

    @Composable
    private fun ConfirmationContentTxFailed(viewModel: ConfirmationTxFailedViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            W3WIcon(
                id = R.drawable.icon_close_24,
                size = 60.dp,
                modifier = Modifier.clip(RoundedCornerShape(30.dp.half))
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.title,
                textAlign = TextAlign.Center,
                style = theme().fonts.title3,
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.error,
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical()
            W3WButtonSecondary(
                title = viewModel.ctaSecondary,
                onClick = { presenter.handle(TxFailedCTASecondaryTapped) }
            )
            W3WSpacerVertical()
            W3WButtonPrimary(
                title = viewModel.cta,
                onClick = { presenter.handle(TxFailedCTATapped) }
            )
        }
    }

    @Composable
    private fun ConfirmationContentTxSuccess(viewModel: ConfirmationTxSuccessViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            W3WIcon(
                id = R.drawable.icon_check_circle_24,
                size = 60.dp,
                colorFilter = ColorFilter.tint(theme().colors.priceUp),
                modifier = Modifier.clip(RoundedCornerShape(30.dp.half))
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.title,
                textAlign = TextAlign.Center,
                style = theme().fonts.title3,
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.message,
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical()
            W3WButtonSecondary(
                title = viewModel.ctaSecondary,
                onClick = { presenter.handle(TxSuccessCTASecondaryTapped) }
            )
            W3WSpacerVertical()
            W3WButtonPrimary(
                title = viewModel.cta,
                onClick = { presenter.handle(TxSuccessCTATapped) }
            )
        }
    }

    @Composable
    private fun ConfirmationContentSend(viewModel: ConfirmationSendViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ConfirmationCurrency(viewModel.currency)
            W3WSpacerVertical()
            ConfirmationAddress(viewModel.address)
            W3WSpacerVertical()
            ConfirmationNetworkFee(viewModel.networkFee)
            W3WSpacerVertical()
            W3WButtonPrimary(title = Localized("confirmation.send.confirm")) {
                presenter.handle(Confirm)
            }
        }
    }

    @Composable
    private fun ConfirmationContentApproveUniswap(viewModel: ConfirmationApproveUniswapViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            W3WIcon(
                id = drawableId(viewModel.iconName),
                size = 60.dp,
                modifier = Modifier.clip(RoundedCornerShape(30.dp.half))
            )
            W3WSpacerVertical()
            W3WText(
                text = Localized(
                    "confirmation.approveUniswap.permission.title",
                    viewModel.symbol.uppercase()
                ),
                style = theme().fonts.title3
            )
            W3WSpacerVertical()
            W3WText(
                text = Localized(
                    "confirmation.approveUniswap.permission.message",
                    viewModel.symbol.uppercase()
                )
            )
            W3WSpacerVertical()
            ConfirmationNetworkFee(viewModel.networkFee)
            W3WSpacerVertical()
            W3WButtonPrimary(title = Localized("confirmation.approveUniswap.confirm")) {
                presenter.handle(Confirm)
            }
        }
    }

    @Composable
    private fun ConfirmationContentSwap(viewModel: ConfirmationSwapViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ConfirmationCurrency(viewModel.currencyFrom)
            W3WSpacerVertical(theme().shapes.padding.half.half.half)
            Box(
                modifier = ModifierCardBackground(
                    cornerRadius = theme().shapes.cornerRadius.half.half
                ).size(24.dp),
                contentAlignment = Alignment.Center,
            ) {
                W3WIcon(id = R.drawable.icon_arrow_downward_24)
            }
            W3WSpacerVertical(theme().shapes.padding.half.half.half)
            ConfirmationCurrency(viewModel.currencyTo)
            W3WSpacerVertical()
            ConfirmationProvider(viewModel.provider)
            W3WSpacerVertical()
            ConfirmationNetworkFee(viewModel.networkFee)
            W3WSpacerVertical()
            W3WButtonPrimary(title = Localized("confirmation.swap.confirm")) {
                presenter.handle(Confirm)
            }
        }
    }

    @Composable
    private fun ConfirmationContentSendNFT(viewModel: ConfirmationSendNFTViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            val screenWidth = LocalConfiguration.current.screenWidthDp
            val imageSize = (screenWidth * 0.4).dp
            W3WImage(
                url = viewModel.nftItem.image,
                modifier = Modifier.requiredSize(imageSize)
            )
            W3WSpacerVertical()
            ConfirmationAddress(viewModel.address)
            W3WSpacerVertical()
            ConfirmationNetworkFee(viewModel.networkFee)
            W3WSpacerVertical()
            W3WButtonPrimary(title = Localized("confirmation.sendNFT.confirm")) {
                presenter.handle(Confirm)
            }
        }
    }

    @Composable
    private fun ConfirmationContentCultCastVote(viewModel: ConfirmationCultCastVoteViewModel) {
        Column(
            modifier = Modifier
                .padding(theme().shapes.padding)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            W3WText(
                text = viewModel.action,
                style = theme().fonts.title3,
            )
            W3WSpacerVertical()
            W3WText(
                text = viewModel.name
            )
            W3WSpacerVertical()
            ConfirmationNetworkFee(viewModel.networkFee)
            W3WSpacerVertical()
            W3WButtonPrimary(title = Localized("confirmation.cultCastVote.confirm")) {
                presenter.handle(Confirm)
            }
        }
    }

    @Composable
    private fun ConfirmationCurrency(viewModel: ConfirmationCurrencyViewModel) {
        Column(
            modifier = ModifierDataBox()
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                W3WIcon(
                    id = drawableId(
                        name = viewModel.iconName,
                        defaultId = R.drawable.icon_default_currency_24,
                    ),
                    size = 32.dp,
                    modifier = Modifier.clip(RoundedCornerShape(32.dp.half))
                )
                W3WSpacerHorizontal()
                Column {
                    W3WText(
                        text = viewModel.value.annotatedStringSubheadline(),
                        modifier = Modifier.fillMaxWidth(),
                    )
                    W3WText(
                        text = viewModel.usdValue.annotatedStringFootnote(),
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
        }
    }

    @Composable
    private fun ConfirmationAddress(viewModel: ConfirmationAddressViewModel) {
        Column(
            modifier = ModifierDataBox(),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                W3WText(
                    text = Localized("confirmation.from"),
                )
                W3WText(
                    text = viewModel.from,
                    textAlign = TextAlign.End,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WDivider()
            W3WSpacerVertical(theme().shapes.padding.half)
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                W3WText(
                    text = Localized("confirmation.to"),
                )
                W3WText(
                    text = viewModel.to,
                    textAlign = TextAlign.End,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }

    @Composable
    private fun ConfirmationProvider(viewModel: ConfirmationProviderViewModel) {
        Column(
            modifier = ModifierDataBox(),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                W3WText(
                    text = Localized("confirmation.provider"),
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
                W3WIcon(
                    id = drawableId(viewModel.iconName),
                )
                W3WText(text = viewModel.name)
            }
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WDivider()
            W3WSpacerVertical(theme().shapes.padding.half)
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                W3WText(
                    text = Localized("confirmation.slippage"),
                )
                W3WText(
                    text = viewModel.slippage,
                    textAlign = TextAlign.End,
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }

    @Composable
    private fun ConfirmationNetworkFee(viewModel: ConfirmationNetworkFeeViewModel) {
        Row(
            modifier = ModifierDataBox(),
        ) {
            W3WText(text = viewModel.title)
            W3WText(
                text = viewModel.value.annotatedStringBody(),
                textAlign = TextAlign.End,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }

    @Composable
    private fun ModifierDataBox(): Modifier = Modifier
        .clip(RoundedCornerShape(theme().shapes.cornerRadius))
        .background(theme().colors.bgPrimary)
        .padding(theme().shapes.padding)
        .fillMaxWidth()
}