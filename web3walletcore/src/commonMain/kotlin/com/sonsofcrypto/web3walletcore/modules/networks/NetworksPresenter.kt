package com.sonsofcrypto.web3walletcore.modules.networks

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderAlchemy
import com.sonsofcrypto.web3lib.provider.ProviderLocal
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.networks.NetworksEvent
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.types.Network.Type.*
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksWireframeDestination.Dashboard
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksWireframeDestination.EditNetwork
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class NetworksPresenterEvent {
    data class DidTapSettings(val chainId: UInt): NetworksPresenterEvent()
    data class DidSwitchNetwork(val chainId: UInt, val isOn: Boolean): NetworksPresenterEvent()
    data class DidSelectNetwork(val chainId: UInt): NetworksPresenterEvent()
}

interface NetworksPresenter {
    fun present()
    fun handle(event: NetworksPresenterEvent)
    fun releaseResources()
}

class DefaultNetworksPresenter(
    private val view: WeakRef<NetworksView>,
    private val wireframe: NetworksWireframe,
    private val interactor: NetworksInteractor,
): NetworksPresenter, NetworkInteractorLister {
    private val uiScope = CoroutineScope(uiDispatcher)

    init { interactor.add(this) }

    override fun present() { updateView() }

    override fun handle(event: NetworksPresenterEvent) {
        when (event) {
            is NetworksPresenterEvent.DidTapSettings -> {
                val network = network(event.chainId) ?: return
                wireframe.navigate(EditNetwork(network))
            }
            is NetworksPresenterEvent.DidSwitchNetwork -> {
                val network = network(event.chainId) ?: return
                interactor.set(network, event.isOn)
            }
            is NetworksPresenterEvent.DidSelectNetwork -> {
                val network = network(event.chainId) ?: return
                if (!interactor.isEnabled(network)) {
                    interactor.set(network, true)
                }
                interactor.selected = network
                wireframe.navigate(Dashboard)
            }
        }
        updateView()
    }

    override fun releaseResources() { interactor.remove(this) }

    override fun handle(event: NetworksEvent) { uiScope.launch { updateView() } }

    private fun updateView() { view.get()?.update(viewModel()) }

    private fun viewModel(): NetworksViewModel {
        val l1s = interactor.networks().filter { it.type == L1 }
        val l2s = interactor.networks().filter { it.type == L2 }
        val l1sTest = interactor.networks().filter { it.type == L1_TEST }
        val l2sTest = interactor.networks().filter { it.type == L2_TEST }
        return NetworksViewModel(
            Localized("networks.header"),
            listOf(
                Section(
                    Localized("networks.header.l1s"),
                    l1s.map { networkViewModel(it) }
                ),
                Section(
                    Localized("networks.header.l2s"),
                    l2s.map { networkViewModel(it) }
                ),
                Section(
                    Localized("networks.header.l1sTest"),
                    l1sTest.map { networkViewModel(it) }
                ),
                Section(
                    Localized("networks.header.l2sTest"),
                    l2sTest.map { networkViewModel(it) }
                )
            ).filter { it.networks.isNotEmpty() }
        )
    }

    private fun networkViewModel(network: Network): NetworksViewModel.Network =
        NetworksViewModel.Network(
            network.chainId,
            network.name,
            interactor.isEnabled(network),
            network.nativeCurrency.iconName,
            formattedProvider(interactor.provider(network)),
            interactor.selected == network,
        )

     private fun formattedProvider(provider: Provider?): String =
        when (provider) {
            is ProviderPocket -> Localized("networks.provider.pokt")
            is ProviderAlchemy -> Localized("networks.provider.alchyme")
            is ProviderLocal -> Localized("networks.provider.local")
            else -> Localized("networks.provider.custom")
        }

    fun network(chaiId: UInt): Network? = interactor.networks().firstOrNull { it.chainId == chaiId }
}
