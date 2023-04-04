package com.sonsofcrypto.web3wallet.android.modules.compose.dashboard

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.dashboard.*
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardPresenterEvent.DidSelectWallet
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardPresenterEvent.DidTapEditNetwork
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Header
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Items.*

class DashboardFragment: Fragment(), DashboardView {

    lateinit var presenter: DashboardPresenter
    private val liveData = MutableLiveData<DashboardViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { DashboardScreen(it) }
            }
        }
    }

    override fun update(viewModel: DashboardViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun DashboardScreen(viewModel: DashboardViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("web3wallet").uppercase()) },
            content = { DashboardContent(viewModel) }
        )
    }

    @Composable
    private fun DashboardContent(viewModel: DashboardViewModel) {
        LazyColumn(
            modifier = Modifier.fillMaxSize()
        ) {
            val totalItems = viewModel.totalItems
            items(totalItems) { indexGeneral ->
                val sections = viewModel.sectionsUpTo(position = indexGeneral)
                val section = sections.last()
                val indexSection = indexGeneral - sections.indexOffset
                if (section.header != null && indexSection == 0) {
                    DashboardContentHeader(
                        header = section.header!!,
                        onClick = {
                            if (section.isWallets) {
                                val index = sections.walletSections.count() - 1
                                presenter.handle(DidTapEditNetwork(index))
                            }
                        }
                    )
                } else {
                    when (val items = section.items) {
                        is Buttons -> {
                            DashboardContentButtons(buttons = items.data)
                        }
                        is Actions -> {
                            DashboardContentActions(actions = items.data)
                        }
                        is Wallets -> {
                            val walletIdx = indexSection - 1
                            items.data.getOrNull(walletIdx)?.let{
                                DashboardContentWallet(
                                    wallet = it,
                                    idx = indexSection - 1,
                                    total = items.data.count(),
                                    onClick = {
                                        val networkIdx = sections.walletSections.count() - 1
                                        presenter.handle(DidSelectWallet(networkIdx, walletIdx))
                                    }
                                )
                                if (walletIdx == items.data.count() - 1) {
                                    W3WSpacerVertical(theme().shapes.padding.half)
                                }
                            }
                        }
                        is Nfts -> {
                            DashboardContentNFTs(nfts = items.data)
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun DashboardContentHeader(
        header: Header,
        onClick: () -> Unit = {}
    ) {
        when (header) {
            is Header.Balance -> {
                W3WText(
                    text = header.title.annotatedStringLargeTitle(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(theme().shapes.padding),
                    textAlign = TextAlign.Center,
                )
            }
            is Header.Title -> {
                Column(
                    modifier = Modifier.padding(
                        start = theme().shapes.padding,
                        end = theme().shapes.padding,
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(
                                top = theme().shapes.padding.half,
                                bottom = theme().shapes.padding.half.half,
                            ),
                    ) {
                        W3WText(
                            text = header.title.uppercase(),
                            modifier = Modifier.weight(1f),
                        )
                        header.action?.let {
                            W3WText(
                                text = it.uppercase(),
                                modifier = ModifierClickable(onClick = onClick),
                            )
                        }
                    }
                    W3WDivider()
                    W3WSpacerVertical(theme().shapes.padding)
                }
            }
        }
    }

    @Composable
    private fun DashboardContentButtons(buttons: List<Button>) {
        Column(
            modifier = Modifier.padding(
                start = theme().shapes.padding,
                end = theme().shapes.padding,
                bottom = theme().shapes.padding,
            )
        ) {
            W3WDivider()
            W3WSpacerVertical()
            Row(
                modifier = Modifier.fillMaxWidth()
            ) {
                DashboardButton(
                    title = buttons[0].title,
                    onClick = { presenter.handle(DashboardPresenterEvent.ReceiveAction) },
                )
                DashboardButton(
                    title = buttons[1].title,
                    onClick = { presenter.handle(DashboardPresenterEvent.SendAction) },
                )
                DashboardButton(
                    title = buttons[2].title,
                    onClick = { presenter.handle(DashboardPresenterEvent.SwapAction) },
                )
            }
        }
    }

    @Composable
    private fun RowScope.DashboardButton(title: String, onClick: () -> Unit) {
        W3WButtonSecondarySmall(
            title = title,
            modifier = Modifier
                .weight(1f)
                .width(100.dp),
            modifierText = Modifier
                .fillMaxWidth()
                .weight(1f),
            onClick = onClick,
        )
    }

    @Composable
    private fun DashboardContentActions(actions: List<Action>) {
        val configuration = LocalConfiguration.current
        val itemWidth = (configuration.screenWidthDp - theme().shapes.padding.value * 3).dp.half
        LazyRow(
            modifier = Modifier.padding(
                top = theme().shapes.padding.half,
                bottom = theme().shapes.padding.half,
            )
        ) {
            items(actions.count()) { index ->
                val action = actions[index]
                W3WSpacerHorizontal()
                Row(
                    modifier = ModifierCardBackground()
                        .width(itemWidth)
                        .padding(
                            top = theme().shapes.padding.half,
                            bottom = theme().shapes.padding.half,
                            start = theme().shapes.padding,
                            end = theme().shapes.padding,
                        )
                        .then(
                            ModifierClickable {
                                presenter.handle(DashboardPresenterEvent.DidTapAction(index))
                            }
                        ),
                    verticalAlignment = Alignment.Top,
                ) {
                    Column(
                        modifier = Modifier
                            .size(24.dp)
                            .clip(shape = RoundedCornerShape(12.dp))
                            .background(theme().colors.navBarTint),
                        verticalArrangement = Arrangement.Center,
                        horizontalAlignment = Alignment.CenterHorizontally,
                    ) {
                        W3WText(
                            text = action.title.first().toString().uppercase(),
                            style = theme().fonts.footnote,
                        )
                    }
                    W3WSpacerHorizontal(theme().shapes.padding.half)
                    Column {
                        W3WText(
                            text = action.title,
                            style = theme().fonts.footnote,
                        )
                        W3WText(
                            text = action.body,
                            style = theme().fonts.caption2,
                            color = theme().colors.textSecondary,
                        )
                    }
                }
                if (action == actions.last()) { W3WSpacerHorizontal() }
            }
        }
    }

    @Composable
    private fun DashboardContentWallet(wallet: Wallet, idx: Int, total: Int, onClick: () -> Unit) {
        Column(
            modifier = ModifierClickable(onClick = onClick)
                .fillMaxWidth()
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                )
                .then(ModifierDynamicBg(idx = idx, total = total))
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                )
        ) {
            Row(
                modifier = Modifier.padding(
                    top = theme().shapes.padding.half,
                    bottom = theme().shapes.padding.half,
                ),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                W3WImage(
                    painter = painterResource(id = App.activity.drawableId(wallet.imageName)),
                    contentDescription = "currency from ${wallet.imageName}",
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                )
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .padding(
                            start = theme().shapes.padding.half,
                            end = theme().shapes.padding.half.half,
                        )
                ) {
                    DashboardContentWalletTableTextTop(wallet = wallet)
                    DashboardContentWalletTableTextBottom(wallet = wallet)
                }
                W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24)
            }
            if (idx != total - 1) { W3WDivider() }
        }
    }

    @Composable
    private fun DashboardContentWalletTableTextTop(wallet: Wallet) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            W3WText(
                text = wallet.name,
            )
            val cryptoBalance = Formatters.currency.format(
                amount = wallet.cryptoBalance,
                currency = wallet.currency,
                style = Formatters.Style.Custom(10u),
                addCurrencySymbol = true
            )
            W3WText(
                text = cryptoBalance.annotatedStringBodyDashboard(),
                textAlign = TextAlign.End,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }

    @Composable
    fun List<Formatters.Output>.annotatedStringBodyDashboard(): AnnotatedString = annotatedString(
        spanStyleNormal = SpanStyle(
            fontSize = theme().fonts.body.fontSize,
            baselineShift = BaselineShift(0.0f),
        ),
        spanStyleUp = SpanStyle(
            fontSize = theme().fonts.caption2.fontSize,
            baselineShift = BaselineShift(0.5f),
        ),
        spanStyleDown = SpanStyle(
            fontSize = theme().fonts.caption2.fontSize,
            baselineShift = BaselineShift(-0.3f),
        ),
    )


    @Composable
    private fun DashboardContentWalletTableTextBottom(wallet: Wallet) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            val fiatPrice = Formatters.fiat.format(
                amount = BigDec.Companion.from(wallet.fiatPrice),
                style = Formatters.Style.Custom(10u),
                currencyCode = wallet.fiatCurrencyCode
            )
            W3WText(
                text = fiatPrice.annotatedStringBodyDashboard(),
                color = theme().colors.textSecondary,
            )
            W3WSpacerHorizontal(theme().shapes.padding.half.half)
            W3WText(
                text = wallet.pctChange,
                color = if (wallet.priceUp) theme().colors.priceUp else theme().colors.priceDown,
            )
            val fiatBalance = Formatters.fiat.format(
                amount = BigDec.Companion.from(wallet.fiatBalance),
                style = Formatters.Style.Custom(10u),
                currencyCode = wallet.fiatCurrencyCode,
            )
            W3WText(
                text = fiatBalance.annotatedStringBodyDashboard(),
                color = theme().colors.textSecondary,
                textAlign = TextAlign.End,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }

    @Composable
    private fun DashboardContentNFTs(nfts: List<NFT>) {
        LazyRow(
            modifier = Modifier.fillMaxWidth(),
            contentPadding = PaddingValues(
                start = theme().shapes.padding,
                end = theme().shapes.padding,
            )
        ) {
            items(nfts.count()) { idx ->
                if (idx != 0) { W3WSpacerHorizontal()  }
                val screenWidth = LocalConfiguration.current.screenWidthDp
                val size = (screenWidth * 0.4).dp
                val item = nfts[idx]
                W3WImage(
                    url = item.image,
                    modifier = Modifier.requiredSize(size),
                    contentDescription = "nft item"
                ) {
                    presenter.handle(DashboardPresenterEvent.DidSelectNFT(idx))
                }
            }
        }
    }
}

private fun DashboardViewModel.sectionsUpTo(position: Int): List<Section> {
    var cursor = 0
    val out = mutableListOf<Section>()
    sections.forEach {
        out.add(it)
        if ((cursor + it.totalItems) <= position) {
            cursor += it.totalItems
        } else {
            return out
        }
    }
    return out
}

/** This calculates how many items were in drawn in the sections up to the last one*/
private val List<Section>.indexOffset: Int get() {
    var items = 0
    forEach {
        if (it != last()) {
            items += it.totalItems
        }
    }
    return items
}

private val List<Section>.walletSections: List<Section> get() = filter {
    when (it.items) {
        is Wallets -> true
        else -> false
    }
}

private val DashboardViewModel.totalItems: Int get() {
    var count = 0
    sections.forEach { count += it.totalItems }
    return count
}

private val Section.totalItems: Int get() {
    var count = 0
    header?.let { count += 1 }
    count += if (items.hasOneRow) 1 else items.count
    return count
}

private val Section.isWallets: Boolean get() = when (this.items) {
    is Wallets -> true
    else -> false
}

private val Section.Items.hasOneRow: Boolean get() = when (this) {
    is Buttons -> true
    is Actions -> true
    is Nfts -> true
    else -> false
}
