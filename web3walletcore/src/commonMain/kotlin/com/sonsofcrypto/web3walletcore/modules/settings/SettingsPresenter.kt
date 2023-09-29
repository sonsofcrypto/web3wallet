package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.utils.EnvUtils
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.DETAIL
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.NONE
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Label
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.DEVELOPER
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.ROOT
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.THEMES

sealed class SettingsPresenterEvent {
    data class Select(val section: Int, val item: Int): SettingsPresenterEvent()
    object Dismiss: SettingsPresenterEvent()
}

interface SettingsPresenter {
    fun present()
    fun handle(event: SettingsPresenterEvent)
}

class DefaultSettingsPresenter(
    private val view: WeakRef<SettingsView>,
    private val wireframe: SettingsWireframe,
    private val interactor: SettingsInteractor,
    private val destination: SettingsWireframeDestination,
): SettingsPresenter {

    override fun present() {
        updateView()
    }

    override fun handle(event: SettingsPresenterEvent) {
        println("[SettingsPresnter] handle $event")
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): Screen = when(destination) {
        ROOT -> Screen(ROOT.value, sectionsForRoot())
        THEMES -> Screen(THEMES.value, sectionsForThemes())
        DEVELOPER -> Screen(DEVELOPER.value, sectionsForDeveloper())
    }

    private fun sectionsForRoot(): List<Section> = listOf(
        Section(
            Localized("settings"),
            listOf(
                Item(Label(Localized("settings.themes"), DETAIL)),
                Item(Label(Localized("settings.improvement"), DETAIL)),
                Item(Label(Localized("settings.feedback"), DETAIL)),
            ) + (
                if (EnvUtils().isProd()) emptyList()
                else listOf(Item(Label(Localized("settings.developer"), DETAIL)))
            ),
            null,
        ),
        Section(
            Localized("sonsofcrypto"),
            listOf(
                Item(Label(Localized("settings.soc.website"), DETAIL)),
                Item(Label(Localized("settings.soc.twitter"), DETAIL)),
                Item(Label(Localized("settings.soc.telegram"), DETAIL)),
                Item(Label(Localized("settings.soc.substack"), DETAIL)),
            ),
            null,
        ),
        Section(
            Localized("settings.docs.title"),
            listOf(
                Item(Label(Localized("settings.docs.cyberspace"), DETAIL)),
                Item(Label(Localized("settings.docs.cypherpunkmanifesto"), DETAIL)),
                Item(Label(Localized("settings.docs.netoworkstate"), DETAIL)),
            ),
        null,
        )
    )

    private fun sectionsForThemes(): List<Section> = listOf(
        Section(
            null,
            listOf(
                Item(Label(Localized("settings.themes.miami.light"), DETAIL)),
                Item(Label(Localized("settings.themes.miami.dark"), DETAIL)),
                Item(Label(Localized("settings.themes.vanilla.light"), DETAIL)),
                Item(Label(Localized("settings.themes.vanilla.dark"), DETAIL)),

            ),
            null,
        )
    )

    private fun sectionsForDeveloper(): List<Section> = listOf(
        Section(
            null,
            listOf(
                Item(Label(Localized("settings.developer.resetKeyStore"), NONE)),
            ),
            null,
        )
    )
}