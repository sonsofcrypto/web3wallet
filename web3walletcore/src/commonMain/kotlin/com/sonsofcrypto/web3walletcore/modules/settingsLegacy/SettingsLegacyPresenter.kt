package com.sonsofcrypto.web3walletcore.modules.settingsLegacy

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyViewModel.Section.Footer
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyViewModel.Section.Item
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyWireframeContext.Group.Footer.Alignment
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.modules.settingsLegacy.SettingsLegacyWireframeDestination.SettingsLegacy
import com.sonsofcrypto.web3walletcore.services.settings.SettingLegacy

sealed class SettingsLegacyPresenterEvent {
    data class Select(val groupIdx: Int, val itemIdx: Int): SettingsLegacyPresenterEvent()
    object Dismiss: SettingsLegacyPresenterEvent()
}

interface SettingsLegacyPresenter {
    fun present()
    fun handle(event: SettingsLegacyPresenterEvent)
}

class DefaultSettingsLegacyPresenter(
    private val view: WeakRef<SettingsLegacyView>,
    private val wireframe: SettingsLegacyWireframe,
    private val interactor: SettingsLegacyInteractor,
    private val context: SettingsLegacyWireframeContext,
): SettingsLegacyPresenter {

    override fun present() { updateView() }

    override fun handle(event: SettingsLegacyPresenterEvent) {
        when (event) {
            is SettingsLegacyPresenterEvent.Select -> {
                val setting = context.groups[event.groupIdx].items[event.itemIdx].settingLegacy
                if (setting.action != null) {
                    interactor.select(setting)
                    updateView()
                } else {
                    wireframe.navigate(SettingsLegacy(SettingsLegacyWireframeContext.create(setting)))
                }
            }
            is SettingsLegacyPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): SettingsLegacyViewModel = SettingsLegacyViewModel(
        context.title,
        context.groups.map { group ->
            Section(
                group.title,
                group.items.map { itemViewModel(it) },
                footerViewModel(group.footer),
            )
        }
    )

    private fun itemViewModel(item: SettingsLegacyWireframeContext.Group.Item): Item = Item(
        item.name,
        itemIsActionViewModel(item.settingLegacy),
        itemIsSelectedViewModel(item.settingLegacy),
    )

    private fun itemIsActionViewModel(settingLegacy: SettingLegacy): Boolean = settingLegacy.action != null

    private fun itemIsSelectedViewModel(settingLegacy: SettingLegacy): Boolean? {
        val action = settingLegacy.action ?: return null
        val showTick = listOf(
            SettingLegacy.Action.THEME_MIAMI_LIGHT,
            SettingLegacy.Action.THEME_MIAMI_DARK,
            SettingLegacy.Action.THEME_IOS_LIGHT,
            SettingLegacy.Action.THEME_IOS_DARK,
            SettingLegacy.Action.DEVELOPER_APIS_NFTS_OPEN_SEA,
            SettingLegacy.Action.DEVELOPER_TRANSITIONS_CARD_FLIP,
            SettingLegacy.Action.DEVELOPER_TRANSITIONS_SHEET,
        ).contains(action)
        if (!showTick) { return null }
        return interactor.isSelected(settingLegacy)
    }

    private fun footerViewModel(footer: SettingsLegacyWireframeContext.Group.Footer?): Footer? {
        footer ?: return null
        return Footer(footer.text, footerAlignmentViewModel(footer.alignment))
    }

    private fun footerAlignmentViewModel(footer: Alignment): Footer.Alignment = when (footer) {
        Alignment.LEFT -> Footer.Alignment.LEFT
        Alignment.CENTER -> Footer.Alignment.CENTER
    }
}