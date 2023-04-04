package com.sonsofcrypto.web3wallet.android.modules.compose.account

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.account.AccountPresenter
import com.sonsofcrypto.web3walletcore.modules.account.AccountPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.account.AccountView
import com.sonsofcrypto.web3walletcore.modules.account.AccountViewModel

class AccountFragment: Fragment(), AccountView {

    lateinit var presenter: AccountPresenter
    private val liveData = MutableLiveData<AccountViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { AccountScreen(it) }
            }
        }
    }
    override fun update(viewModel: AccountViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun AccountScreen(viewModel: AccountViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.currencyName) },
            content = { AccountContent(viewModel) },
        )
    }

    @Composable
    private fun AccountContent(viewModel: AccountViewModel) {
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                )
        ) {
            items(1 + viewModel.transactions.size) {
                if (it == 0) { AccountGeneralInfo(viewModel) }
                else {
                    val idx = it - 1
                    if (idx == 0) { AccountTransactionHeader() }
                    AccountTransaction(
                        viewModel = viewModel.transactions[idx],
                        idx = idx,
                        total = viewModel.transactions.size,
                    )
                    if (idx == viewModel.transactions.size - 1) { W3WSpacerVertical() }
                }
            }
        }
    }

    @Composable
    private fun AccountGeneralInfo(viewModel: AccountViewModel) {
        Column {
            W3WSpacerVertical()
            AccountBalance(viewModel)
            W3WSpacerVertical()
            AccountActions(viewModel.header)
            W3WSpacerVertical()
            AccountAddress(viewModel.address) { App.copyToClipboard(viewModel.address.address) }
            W3WSpacerVertical()
            AccountMarketInfo(viewModel.marketInfo)
            viewModel.bonusAction?.let {
                W3WSpacerVertical()
                // TODO: Improve so it works for multiple actions currently just for CULT
                AccountBonusAction(it) { App.openUrl("https://cultdao.io/manifesto.pdf") }
            }
            W3WSpacerVertical()
        }
    }

    @Composable
    private fun AccountBalance(viewModel: AccountViewModel) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WText(
                text = viewModel.header.balance.annotatedStringLargeTitle(),
                textAlign = TextAlign.Center,
            )
            W3WText(
                text = viewModel.header.fiatBalance.annotatedStringBody(),
                textAlign = TextAlign.Center,
            )
        }
    }

    @Composable
    private fun AccountActions(viewModel: AccountViewModel.Header) {
        Row {
            viewModel.buttons.forEach {
                val idx = viewModel.buttons.indexOf(it)
                AccountButton(
                    iconId = accountButtonIconId(idx),
                    button = it,
                    onClick = { accountButtonActionTapped(idx) },
                )
                if (it != viewModel.buttons.last()) { W3WSpacerHorizontal() }
            }
        }
    }

    private fun accountButtonIconId(idx: Int): Int = when(idx) {
        0 -> { R.drawable.icon_qr_code_scanner_24 }
        1 -> { R.drawable.icon_arrow_forward_24 }
        2 -> { R.drawable.icon_swap_horiz_24 }
        else -> { R.drawable.icon_more_horiz_24 }
    }

    private fun accountButtonActionTapped(idx: Int) = when(idx) {
        0 -> { presenter.handle(AccountPresenterEvent.Receive) }
        1 -> { presenter.handle(AccountPresenterEvent.Send) }
        2 -> { presenter.handle(AccountPresenterEvent.Swap) }
        else -> { presenter.handle(AccountPresenterEvent.More) }
    }

    @Composable
    private fun RowScope.AccountButton(
        iconId: Int,
        button: AccountViewModel.Header.Button,
        onClick: () -> Unit,
    ) {
        Column(
            modifier = ModifierCardBackground(cornerRadius = theme().shapes.cornerRadiusSmall)
                .then(ModifierClickable(onClick = onClick))
                .padding(theme().shapes.padding.half)
                .weight(1f),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WIcon(id = iconId)
            W3WSpacerVertical(theme().shapes.padding.half.half)
            W3WText(
                text = button.title,
                style = theme().fonts.footnote,
            )
        }
    }

    @Composable
    private fun AccountAddress(
        viewModel: AccountViewModel.Address,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .then(ModifierCardBackground())
                .then(ModifierClickable(onClick = onClick))
                .padding(theme().shapes.padding),
            horizontalArrangement = Arrangement.Center,
        ) {
            W3WText(text = viewModel.addressFormatted)
            W3WSpacerHorizontal()
            W3WIcon(id = R.drawable.icon_copy_24)
        }
    }

    @Composable
    private fun AccountMarketInfo(viewModel: AccountViewModel.MarketInfo) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .then(ModifierCardBackground())
                .padding(theme().shapes.padding),
        ) {
            AccountMarketInfoItem(
                title = Localized("account.marketInfo.marketCap"),
                value = viewModel.marketCap,
            )
            AccountMarketInfoItem(
                title = Localized("account.marketInfo.price"),
                value = viewModel.price,
            )
            AccountMarketInfoItem(
                title = Localized("account.marketInfo.volume"),
                value = viewModel.volume,
            )
        }
    }

    @Composable
    private fun RowScope.AccountMarketInfoItem(
        title: String,
        value: List<Formatters.Output>,
    ) {
        Column(
            modifier = Modifier.weight(1f),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WText(
                text = title,
                color = theme().colors.textSecondary,
                style = theme().fonts.footnote,
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical(theme().shapes.padding.half.half.half)
            W3WText(
                text = value.annotatedStringSubheadline(),
                style = theme().fonts.footnote,
                textAlign = TextAlign.Center,
            )
        }
    }

    @Composable
    private fun AccountBonusAction(
        viewModel: AccountViewModel.BonusAction,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .then(ModifierCardBackground())
                .then(ModifierClickable(onClick = onClick))
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding.half,
                    top = theme().shapes.padding,
                    bottom = theme().shapes.padding,
                ),
        ) {
            W3WText(
                text = viewModel.title,
                style = theme().fonts.bodyBold,
                modifier = Modifier.weight(1f),
            )
            W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24)
        }
    }

    @Composable
    private fun AccountTransactionHeader() {
        Column(
            modifier = Modifier.fillMaxWidth(),
        ) {
            W3WText(
                text = Localized("account.marketInfo.transactions"),
                style = theme().fonts.subheadline,
            )
            W3WSpacerVertical(theme().shapes.padding.half)
        }
    }

    @Composable
    private fun AccountTransaction(
        viewModel: AccountViewModel.Transaction,
        idx: Int,
        total: Int,
    ) {
        Row(
            modifier = ModifierClickable {
                val txHash = viewModel.txHash ?: return@ModifierClickable
                App.openUrl("https://etherscan.io/tx/$txHash")
            }
                .then(ModifierDynamicBg(idx = idx, total = total))
                .padding(
                    end = theme().shapes.padding.half,
                )
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(
                        start = theme().shapes.padding,
                        end = theme().shapes.padding.half,
                        top = theme().shapes.padding,
                        bottom = theme().shapes.padding,
                    )
                    .weight(1f),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                when (viewModel) {
                    is AccountViewModel.Transaction.Empty -> {
                        W3WText(
                            text = viewModel.text,
                            color = theme().colors.textSecondary,
                            style = theme().fonts.callout,
                        )
                    }
                    is AccountViewModel.Transaction.Loading -> {
                        W3WLoading(
                            modifier = Modifier.size(24.dp)
                        )
                        W3WSpacerVertical(theme().shapes.padding.half)
                        W3WText(
                            text = viewModel.text,
                            color = theme().colors.textSecondary,
                            style = theme().fonts.callout,
                        )
                    }
                    is AccountViewModel.Transaction.Loaded -> {
                        Row(
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            W3WText(
                                text = viewModel.data.date,
                                style = theme().fonts.callout,
                            )
                            W3WText(
                                text = viewModel.data.amount.annotatedStringCallout(),
                                textAlign = TextAlign.End,
                                modifier = Modifier.weight(1f),
                            )
                        }
                        W3WSpacerVertical(theme().shapes.padding.half)
                        Row(
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            W3WText(
                                text = viewModel.data.address,
                                color = theme().colors.textSecondary,
                                style = theme().fonts.callout,
                            )
                            W3WText(
                                text = viewModel.data.fiatPrice.annotatedStringCallout(),
                                textAlign = TextAlign.End,
                                color = theme().colors.textSecondary,
                                modifier = Modifier.weight(1f),
                            )
                        }
                    }
                }
            }
            if (viewModel.txHash != null) { W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24) }
        }
        if (idx != total - 1) {
            W3WDivider(
                modifier = Modifier
                    .background(theme().colors.bgPrimary)
                    .padding(
                        start = theme().shapes.padding,
                        end = theme().shapes.padding,
                    )
            )
        }
    }
}

private val AccountViewModel.Transaction.txHash: String? get() = when (val tx = this) {
    is AccountViewModel.Transaction.Loaded -> { tx.data.txHash }
    else -> null
}
