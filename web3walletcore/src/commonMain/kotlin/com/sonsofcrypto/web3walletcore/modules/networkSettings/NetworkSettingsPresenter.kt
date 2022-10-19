package com.sonsofcrypto.web3walletcore.modules.networkSettings

import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.services.networks.ProviderInfo
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.networkSettings.NetworkSettingsViewModel.Item

sealed class NetworkSettingsPresenterEvent {
    /** Did select provider at index */
    data class Select(val idx: Int): NetworkSettingsPresenterEvent()
}

interface NetworkSettingsPresenter {
    fun present()
    fun handle(event: NetworkSettingsPresenterEvent)
}

class DefaultNetworkSettingsPresenter(
    private val view: WeakRef<NetworkSettingsView>,
    private val interactor: NetworkSettingsInteractor,
    private val network: Network,
): NetworkSettingsPresenter {

    override fun present() {
        updateView()
    }

    override fun handle(event: NetworkSettingsPresenterEvent) {
        when (event) {
            is NetworkSettingsPresenterEvent.Select -> interactor.select(
                interactor.supportedProviderTypes(network)[event.idx],
                network
            )
        }
        updateView()
    }

    private fun updateView() {
        view.value?.update(viewModel())
    }

    private fun viewModel(): NetworkSettingsViewModel {
        val supported = interactor.supportedProviderTypes(network)
        val selected = supported.indexOf(interactor.selectedType(network))
        return NetworkSettingsViewModel(
            supported.map { Item(title(it)) },
            selected
        )
    }

    private fun title(type: ProviderInfo.Type): String =  when (type) {
        ProviderInfo.Type.POCKET -> Localized("networks.provider.pokt")
        ProviderInfo.Type.ALCHEMY -> Localized("networks.provider.alchyme")
        ProviderInfo.Type.LOCAL -> Localized("networks.provider.local")
        else -> Localized("networks.provider.custom")
    }
}
