package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsViewModel.Section.Footer
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsViewModel.Section.Item
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeContext.Group.Footer.Alignment
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Dismiss
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Settings
import com.sonsofcrypto.web3walletcore.services.settings.Setting

sealed class SettingsPresenterEvent {
    data class Select(val groupIdx: Int, val itemIdx: Int): SettingsPresenterEvent()
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
    private val context: SettingsWireframeContext,
): SettingsPresenter {

    override fun present() { updateView() }

    override fun handle(event: SettingsPresenterEvent) {
        when (event) {
            is SettingsPresenterEvent.Select -> {
                val setting = context.groups[event.groupIdx].items[event.itemIdx].setting
                if (setting.action != null) {
                    interactor.select(setting)
                    updateView()
                } else {
                    wireframe.navigate(Settings(SettingsWireframeContext.create(setting)))
                }
            }
            is SettingsPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): SettingsViewModel = SettingsViewModel(
        context.title,
        context.groups.map { group ->
            Section(
                group.title,
                group.items.map { itemViewModel(it) },
                footerViewModel(group.footer),
            )
        }
    )

    private fun itemViewModel(item: SettingsWireframeContext.Group.Item): Item = Item(
        item.name,
        itemIsActionViewModel(item.setting),
        itemIsSelectedViewModel(item.setting),
    )

    private fun itemIsActionViewModel(setting: Setting): Boolean = setting.action != null

    private fun itemIsSelectedViewModel(setting: Setting): Boolean? {
        val action = setting.action ?: return null
        val showTick = listOf(
            Setting.Action.THEME_MIAMI_LIGHT,
            Setting.Action.THEME_MIAMI_DARK,
            Setting.Action.THEME_IOS_LIGHT,
            Setting.Action.THEME_IOS_DARK,
            Setting.Action.DEVELOPER_APIS_NFTS_OPEN_SEA,
            Setting.Action.DEVELOPER_TRANSITIONS_CARD_FLIP,
            Setting.Action.DEVELOPER_TRANSITIONS_SHEET,
        ).contains(action)
        if (!showTick) { return null }
        return interactor.isSelected(setting)
    }

    private fun footerViewModel(footer: SettingsWireframeContext.Group.Footer?): Footer? {
        footer ?: return null
        return Footer(footer.text, footerAlignmentViewModel(footer.alignment))
    }

    private fun footerAlignmentViewModel(footer: Alignment): Footer.Alignment = when (footer) {
        Alignment.LEFT -> Footer.Alignment.LEFT
        Alignment.CENTER -> Footer.Alignment.CENTER
    }
}