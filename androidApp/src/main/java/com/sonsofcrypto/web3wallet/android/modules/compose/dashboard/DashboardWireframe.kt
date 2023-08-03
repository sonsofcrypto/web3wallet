package com.sonsofcrypto.web3wallet.android.modules.compose.dashboard

import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3lib.services.currencyStore.CurrencyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.navigationFragment
import com.sonsofcrypto.web3wallet.android.modules.compose.account.AccountWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker.CurrencyPickerWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive.CurrencyReceiveWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencysend.CurrencySendWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap.CurrencySwapWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposals.ImprovementProposalsWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation.MnemonicConfirmationWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.nftdetail.NFTDetailWireframeFactory
import com.sonsofcrypto.web3wallet.android.modules.compose.qrcodescan.QRCodeScanWireframeFactory
import com.sonsofcrypto.web3walletcore.modules.account.AccountWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerWireframeContext.NetworkData
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframeContext
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframe
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.EditCurrencies
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.ImprovementProposals
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.KeyStoreNetworkSettings
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.MnemonicConfirmation
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.NftItem
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.Receive
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.ScanQRCode
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.Send
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.Swap
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.ThemePicker
import com.sonsofcrypto.web3walletcore.modules.dashboard.DashboardWireframeDestination.Wallet
import com.sonsofcrypto.web3walletcore.modules.dashboard.DefaultDashboardInteractor
import com.sonsofcrypto.web3walletcore.modules.dashboard.DefaultDashboardPresenter
import com.sonsofcrypto.web3walletcore.modules.nftDetail.NFTDetailWireframeContext
import com.sonsofcrypto.web3walletcore.modules.qrCodeScan.QRCodeScanWireframeContext
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

class DefaultDashboardWireframe(
    private val parent: WeakRef<Fragment>?,
    private val networksService: NetworksService,
    private val currencyStoreService: CurrencyStoreService,
    private val walletService: WalletService,
    private val nftsService: NFTsService,
    private val actionsService: ActionsService,
    private val currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
    private val currencySendWireframeFactory: CurrencySendWireframeFactory,
    private val currencySwapWireframeFactory: CurrencySwapWireframeFactory,
    private val currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
    private val accountWireframeFactory: AccountWireframeFactory,
    private val nftDetailWireframeFactory: NFTDetailWireframeFactory,
    private val mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
    private val improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory,
    private val qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
): DashboardWireframe {

    override fun present() {
        val fragment = wireUp()
        parent?.navigationFragment?.push(fragment, animated = true)
    }

    override fun navigate(destination: DashboardWireframeDestination) {
        when (destination) {
            is Wallet -> {
                val context = AccountWireframeContext(destination.network, destination.currency)
                accountWireframeFactory.make(parent?.get(), context).present()
            }
            is KeyStoreNetworkSettings -> {
                println("[AA] navigate to KeyStoreNetworkSettings")
            }
            is ScanQRCode -> {
                val network = networksService.network ?: return
                val context = QRCodeScanWireframeContext(
                    type = QRCodeScanWireframeContext.Type.Network(network),
                    handler = { addressTo -> navigate(Send(addressTo)) }
                )
                qrCodeScanWireframeFactory.make(parent?.get(), context).present()
            }
            is MnemonicConfirmation -> {
                mnemonicConfirmationWireframeFactory.make(parent?.get()).present()
            }
            is ThemePicker -> {
                println("[AA] navigate to ThemePicker")
            }
            is ImprovementProposals -> {
                improvementProposalsWireframeFactory.make(parent?.get()).present()
            }
            is Receive -> {
                navigateToReceive()
            }
            is Send -> {
                navigateToSend(destination)
            }
            is Swap -> {
                val network = networksService.network ?: return
                val context = CurrencySwapWireframeContext(network, null, null)
                currencySwapWireframeFactory.make(parent?.get(), context).present()
            }
            is EditCurrencies -> {
                navigateToEditCurrencies(destination)
            }
            is NftItem -> {
                val context = NFTDetailWireframeContext(
                    destination.nft.identifier, destination.nft.collectionIdentifier
                )
                nftDetailWireframeFactory.make(parent?.get(), context).present()
            }
            else -> { println("[AA] navigate to $destination") }
        }
    }

    private fun wireUp(): Fragment {
        val view = DashboardFragment()
        val interactor = DefaultDashboardInteractor(
            networksService,
            currencyStoreService,
            walletService,
            nftsService,
            actionsService,
        )
        val presenter = DefaultDashboardPresenter(
            WeakRef(view),
            this,
            interactor
        )
        view.presenter = presenter
        return view
    }

    private fun navigateToReceive() {
        val context = CurrencyPickerWireframeContext(
            isMultiSelect = false,
            showAddCustomCurrency = false,
            networksData = networksService.enabledNetworks().map {
                NetworkData(it, null, null)
            },
            selectedNetwork = null,
            handler = {
                it.firstOrNull()?.let { result ->
                    result.selectedCurrencies.firstOrNull()?.let { currency ->
                        val context = CurrencyReceiveWireframeContext(
                            network = result.network,
                            currency= currency,
                        )
                        currencyReceiveWireframeFactory.make(
                            parent?.get(), context
                        ).present()
                    }
                }
            }
        )
        currencyPickerWireframeFactory.make(parent?.get(), context).present()
    }

    private fun navigateToSend(destination: Send) {
        if (destination.addressTo != null) {
            val network = networksService.network ?: return
            val context = CurrencySendWireframeContext(
                network = network,
                address = destination.addressTo,
                currency= null,
            )
            currencySendWireframeFactory.make(parent?.get(), context).present()
        } else {
            val context = CurrencyPickerWireframeContext(
                isMultiSelect = false,
                showAddCustomCurrency = false,
                networksData = networksService.enabledNetworks().map {
                    NetworkData(it, null, null)
                },
                selectedNetwork = null,
                handler = {
                    it.firstOrNull()?.let { result ->
                        result.selectedCurrencies.firstOrNull()?.let { currency ->
                            val context = CurrencySendWireframeContext(
                                network = result.network,
                                address = null,
                                currency= currency,
                            )
                            currencySendWireframeFactory.make(parent?.get(), context).present()
                        }
                    }
                }
            )
            currencyPickerWireframeFactory.make(parent?.get(), context).present()
        }
    }

    private fun navigateToEditCurrencies(destination: EditCurrencies) {

        val context = CurrencyPickerWireframeContext(
            isMultiSelect = true,
            showAddCustomCurrency = true,
            networksData = listOf(
                NetworkData(destination.network, destination.selectedCurrencies, null)
            ),
            selectedNetwork = null,
            handler = {
                if (it.firstOrNull() != null) {
                    destination.onCompletion(it.first().selectedCurrencies)
                }
            }
        )
        currencyPickerWireframeFactory.make(parent?.get(), context).present()
    }
}