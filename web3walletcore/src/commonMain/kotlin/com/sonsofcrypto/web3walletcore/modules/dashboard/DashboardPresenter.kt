package com.sonsofcrypto.web3walletcore.modules.dashboard

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.coinGecko.model.Candle
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.bgDispatcher
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.viewModels.CandlesViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Header.Balance
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Header.Title
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Items.*
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardViewModel.Section.Items.Button.Type.*
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.KeyStoreNetworkSettings
import com.sonsofcrypto.web3walletcore.services.actions.Action
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class DashboardPresenterEvent {
    object WalletConnectionSettingsAction: DashboardPresenterEvent()
    object DidInteractWithCardSwitcher: DashboardPresenterEvent()
    object DidScanQRCode: DashboardPresenterEvent()
    object PullDownToRefresh: DashboardPresenterEvent()
    object ReceiveAction: DashboardPresenterEvent()
    object SendAction: DashboardPresenterEvent()
    object SwapAction: DashboardPresenterEvent()
    data class DidTapAction(val idx: Int): DashboardPresenterEvent()
    data class DidTapDismissAction(val idx: Int): DashboardPresenterEvent()
    data class DidSelectWallet(val networkIdx: Int, val currencyIdx: Int): DashboardPresenterEvent()
    data class DidTapEditNetwork(val idx: Int): DashboardPresenterEvent()
    data class DidSelectNFT(val idx: Int): DashboardPresenterEvent()
}

interface DashboardPresenter {
    fun present()
    fun handle(event: DashboardPresenterEvent)
    fun didEnterBackground()
    fun willEnterForeground()
    fun releaseResources()
}

class DefaultDashboardPresenter(
    private val view: WeakRef<DashboardView>,
    private val wireframe: DashboardWireframe,
    private val interactor: DashboardInteractor,
): DashboardPresenter, DashboardInteractorLister {
    private val bgScope = CoroutineScope(bgDispatcher)
    private val uiScope = CoroutineScope(uiDispatcher)
    private var actions = listOf<Action>()
    private var networks = listOf<Network>()
    private var nfts = listOf<NFTItem>()

    init {
        interactor.addListener(this)
    }

    override fun releaseResources() {
        interactor.removeListener(this)
    }

    override fun present() {
        interactor.reloadData()
        updateView()
    }

    override fun handle(event: DashboardPresenterEvent) {
        when (event) {
            is DashboardPresenterEvent.WalletConnectionSettingsAction -> {
                wireframe.navigate(KeyStoreNetworkSettings)
            }
            is DashboardPresenterEvent.DidInteractWithCardSwitcher -> {
                updateView()
            }
            is DashboardPresenterEvent.DidScanQRCode -> {
                wireframe.navigate(DashboardWireframeDestination.ScanQRCode)
            }
            is DashboardPresenterEvent.PullDownToRefresh -> {
                interactor.reloadData()
            }
            is DashboardPresenterEvent.ReceiveAction -> {
                wireframe.navigate(DashboardWireframeDestination.Receive)
            }
            is DashboardPresenterEvent.SendAction -> {
                wireframe.navigate(DashboardWireframeDestination.Send(null))
            }
            is DashboardPresenterEvent.SwapAction -> {
                wireframe.navigate(DashboardWireframeDestination.Swap)
            }
            is DashboardPresenterEvent.DidTapAction -> {
                didTapAction(event.idx)
            }
            is DashboardPresenterEvent.DidTapDismissAction -> {
                interactor.dismissAction(actions[event.idx])
            }
            is DashboardPresenterEvent.DidSelectWallet -> {
                val network = networks[event.networkIdx]
                val currency = interactor.currencies(network)[event.currencyIdx]
                wireframe.navigate(DashboardWireframeDestination.Wallet(network, currency))
            }
            is DashboardPresenterEvent.DidTapEditNetwork -> {
                didTapEditNetwork(networks[event.idx])
            }
            is DashboardPresenterEvent.DidSelectNFT -> {
                wireframe.navigate(DashboardWireframeDestination.NftItem(nfts[event.idx]))
            }
        }
    }

    override fun didEnterBackground() { interactor.didEnterBackground() }

    override fun willEnterForeground() { interactor.willEnterForeground() }

    override fun handle(event: DashboardInteractorEvent) {
        bgScope.launch {
            delay(5000)
            uiScope.launch { updateView() }
        }
    }

    private fun updateView() {
        actions = interactor.actions()
        networks = interactor.enabledNetworks()
        nfts = interactor.nfts(Network.ethereum())
        view.get()?.update(viewModel())
    }

    private fun viewModel(): DashboardViewModel = DashboardViewModel(sections())

    private fun sections(): List<Section> {
        val sections = mutableListOf<Section>()
        sections.add(balanceSection())
        actionsSection()?.let { sections.add(it) }
        sections.addAll(networksSection())
        nftsSection()?.let { sections.add(it) }
        return sections
    }

    private fun balanceSection(): Section = Section(
        balanceHeader(),
        balanceItems(),
    )

    private fun balanceHeader(): Section.Header = Balance(
        Formatters.fiat.format(
            BigDec.from(interactor.totalFiatBalance()),
            Formatters.Style.Custom(15u),
            "usd"
        )
    )

    private fun balanceItems(): Section.Items = Buttons(
        listOf(
            Button(
                Localized("dashboard.button.receive"),
                "receive-button",
                RECEIVE
            ),
            Button(
                Localized("dashboard.button.send"),
                "send-button",
                SEND
            ),
            Button(
                Localized("dashboard.button.swap"),
                "swap-button",
                SWAP
            )
        )
    )

    private fun actionsSection(): Section? {
        if (actions.isEmpty()) return null
        return Section(
            null,
            actionsItems()
        )
    }

    private fun actionsItems(): Section.Items = Actions(
        actions.map { Action(it.imageName, it.title, it.body) }
    )

    private fun networksSection(): List<Section> = networks.map {
        Section(
            networkHeader(it),
            networkItems(it)
        )
    }

    private fun networkHeader(network: Network): Section.Header = Title(
        network.name, Localized("more").uppercase()
    )

    private fun networkItems(network: Network): Section.Items = Wallets(
        interactor.currencies(network).map { walletItem(network, it) }
    )

    private fun walletItem(network: Network, currency: Currency): Wallet {
        val market = interactor.marketdata(currency)
        val metadata = interactor.metadata(currency)
        val fiatPrice = market?.currentPrice ?: 0.0
        val fiatBalance = interactor.fiatBalance(network, currency)
        val cryptoBalance = interactor.cryptoBalance(network, currency)
        return Wallet(
            name = currency.name,
            ticker = currency.symbol.uppercase(),
            colors = metadata?.colors ?: listOf("#FFFFFF", "#000000"),
            imageName = currency.iconName,
            fiatPrice = fiatPrice,
            fiatBalance = fiatBalance,
            cryptoBalance = cryptoBalance,
            currency = currency,
            pctChange = Formatters.pct.format(market?.priceChangePercentage24h, true),
            priceUp = (market?.priceChangePercentage24h ?: 0.toDouble()) >= 0,
            candles = walletCandles(interactor.candles(currency)),
            fiatCurrencyCode = "usd",
        )
    }

    private fun walletCandles(candles: List<Candle>?): CandlesViewModel {
        candles ?: return CandlesViewModel.Loading(40)
        return CandlesViewModel.Loaded(
            candles.takeLast(40).map {
                CandlesViewModel.Candle(
                    it.open,
                    it.high,
                    it.low,
                    it.close,
                    0.toDouble(),
                    it.timestamp.epochSeconds.toDouble()
                )
            }
        )
    }

    private fun nftsSection(): Section? {
        if (nfts.isEmpty()) return null
        return Section(
            Title(Localized("dashboard.section.nfts").uppercase(), null),
            nftsItems()
        )
    }

    private fun nftsItems(): Section.Items = Nfts(nfts.map { NFT(it.image) })

    private fun didTapAction(idx: Int) {
        if (actions[idx] is Action.ConfirmMnemonic) {
            wireframe.navigate(DashboardWireframeDestination.MnemonicConfirmation)
        }
        if (actions[idx] is Action.Themes) {
            wireframe.navigate(DashboardWireframeDestination.ThemePicker)
        }
        if (actions[idx] is Action.ImprovementProposals) {
            wireframe.navigate(DashboardWireframeDestination.ImprovementProposals)
        }
    }

    private fun didTapEditNetwork(network: Network) {
        wireframe.navigate(
            DashboardWireframeDestination.EditCurrencies(
                network,
                interactor.currencies(network)
            ) {
                interactor.setCurrencies(it, network)
                updateView()
                interactor.reloadData()
            }
        )
    }
}