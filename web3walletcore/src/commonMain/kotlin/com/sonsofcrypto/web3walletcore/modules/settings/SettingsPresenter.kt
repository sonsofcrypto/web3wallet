package com.sonsofcrypto.web3walletcore.modules.settings

import com.sonsofcrypto.web3lib.utils.EnvUtils
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3lib.utils.uiDispatcher
import com.sonsofcrypto.web3walletcore.common.ThemeId
import com.sonsofcrypto.web3walletcore.common.ThemeVariant
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.CHECKMARK
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.DETAIL
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Accessory.NONE
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Label
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Switch
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Header.Title
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsPresenterEvent.Select
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsScreenId.DEVELOPER
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsScreenId.ROOT
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsScreenId.THEMES
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsScreenId.UITWEAKS
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Improvements
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.KeyStore
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Mail
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Settings
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsWireframeDestination.Website
import com.sonsofcrypto.web3walletcore.services.settings.NFTCarouselSize
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed class SettingsPresenterEvent {
    data class Select(val section: Int, val item: Int): SettingsPresenterEvent()
}

interface SettingsPresenter {
    fun present()
    fun handle(event: SettingsPresenterEvent)
}

class DefaultSettingsPresenter(
    private val view: WeakRef<SettingsView>,
    private val wireframe: SettingsWireframe,
    private val interactor: SettingsInteractor,
    private val screenId: SettingsScreenId,
): SettingsPresenter {

    override fun present() {
        updateView()
    }

    override fun handle(event: SettingsPresenterEvent) {
        if (event is Select)
            when (screenId) {
                ROOT -> handleEventForRoot(event)
                THEMES -> handleEventForThemes(event)
                UITWEAKS -> handleEventForUITweaks(event)
                DEVELOPER -> handleEventForThemes(event)
            }
    }

    private fun handleEventForRoot(e: Select) = when {
        // Settings
        e.section == 0 && e.item == 0 -> wireframe.navigate(Settings(THEMES))
        e.section == 0 && e.item == 1 -> wireframe.navigate(Settings(UITWEAKS))
        e.section == 0 && e.item == 2 -> {
            interactor.expertMode = !interactor.expertMode
            updateView()
        }
        e.section == 0 && e.item == 3 -> wireframe.navigate(Settings(DEVELOPER))
        // Sons of crypto
        e.section == 1 && e.item == 0 -> wireframe.navigate(Mail)
        e.section == 1 && e.item == 1 -> wireframe.navigate(Improvements)
        e.section == 1 && e.item == 2 -> wireframe.navigate(
            Website("https://www.sonsofcrypto.com")
        )
        e.section == 1 && e.item == 3 -> wireframe.navigate(
            Website("https://www.twitter.com/sonsofcryptolab")
        )
        e.section == 1 && e.item == 4 -> wireframe.navigate(
            Website("https://t.me/socweb3")
        )
        e.section == 1 && e.item == 5 -> wireframe.navigate(
            Website("https://sonsofcrypto.substack.com/")
        )
        // web3wallet stands for
        e.section == 2 && e.item == 0 -> wireframe.navigate(
            Website("https://www.eff.org/cyberspace-independence")
        )
        e.section == 2 && e.item == 1 -> wireframe.navigate(
            Website("https://nakamotoinstitute.org/static/docs/cypherpunk-manifesto.txt")
        )
        e.section == 2 && e.item == 2 -> wireframe.navigate(
            Website("https://thenetworkstate.com/")
        )
        else -> { }
    }

    private fun handleEventForThemes(e: Select) {
        when {
            e.section == 0 && e.item == 0 -> {
                interactor.themeId = ThemeId.MIAMI
                interactor.themeVariant = ThemeVariant.LIGHT
            }
            e.section == 0 && e.item == 1 -> {
                interactor.themeId = ThemeId.MIAMI
                interactor.themeVariant = ThemeVariant.DARK
            }
            e.section == 0 && e.item == 2 -> {
                interactor.themeId = ThemeId.VANILLA
                interactor.themeVariant = ThemeVariant.LIGHT
            }
            e.section == 0 && e.item == 3 -> {
                interactor.themeId = ThemeId.VANILLA
                interactor.themeVariant = ThemeVariant.DARK
            }
            else -> {}
        }
        view.get()?.updateThemeAndRefreshTraits()
        updateViewOnNextRunLoop()
    }

    private fun handleEventForUITweaks(e: Select) {
        when {
            e.section == 0 && e.item == 0 -> {
                interactor.nftCarouselSize = NFTCarouselSize.REGULAR
            }
            e.section == 0 && e.item == 1 -> {
                interactor.nftCarouselSize = NFTCarouselSize.LARGE
            }
        }
        view.get()?.refreshTraits()
        updateViewOnNextRunLoop()
    }

    private fun handleEventForDeveloper(e: Select) = when {
        e.section == 0 && e.item == 0 -> {
            interactor.resetKeyStore()
            wireframe.navigate(KeyStore)
        }
        else -> {}
    }

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun updateViewOnNextRunLoop() {
        CoroutineScope(uiDispatcher).launch {
            delay(20.toLong())
            updateView()
        }
    }

    private fun viewModel(): Screen = when(screenId) {
        ROOT -> Screen(ROOT.value, sectionsForRoot())
        THEMES -> Screen(THEMES.value, sectionsForThemes())
        UITWEAKS -> Screen(UITWEAKS.value, sectionsForUITweaks())
        DEVELOPER -> Screen(DEVELOPER.value, sectionsForDeveloper())
    }

    private fun sectionsForRoot(): List<Section> {
        val img = listOf(
            "theatermask.and.paintbrush", "gear", "brain",
            "dot.scope.laptopcomputer", "ant", "signpost.right.and.left",
            "globe", "bird", "paperplane", "doc.append", "scroll", "key", "flag"
        ).map { SysName(it) }
        return listOf(
            Section(
                Title(Localized("settings")),
                listOf(
                    Label(Localized("settings.themes"), DETAIL, image = img[0]),
                    Label(Localized("settings.uitweaks"), DETAIL, image = img[1]),
                    Switch(
                        Localized("settings.expertMode"),
                        interactor.expertMode,
                        image = img[2]
                    ),
                ) + (
                    if (EnvUtils().isProd()) emptyList()
                    else listOf(
                        Label(
                            Localized("settings.developer"),
                            DETAIL,
                            image = img[3]
                        )
                    )
                ),
                null,
            ),
            Section(
                Title(Localized("sonsofcrypto")),
                listOf(
                    Label(Localized("settings.feedback"), DETAIL, image = img[4]),
                    Label(Localized("settings.improvement"), DETAIL, image = img[5]),
                    Label(Localized("settings.soc.website"), DETAIL, image = img[6]),
                    Label(Localized("settings.soc.twitter"), DETAIL, image = img[7]),
                    Label(Localized("settings.soc.telegram"), DETAIL, image = img[8]),
                    Label(Localized("settings.soc.substack"), DETAIL, image = img[9]),
                ),
                null,
            ),
            Section(
                Title(Localized("settings.docs.title")),
                listOf(
                    Label(Localized("settings.docs.cyberspace"), DETAIL, image = img[10]),
                    Label(Localized("settings.docs.cypherpunkmanifesto"), DETAIL, image = img[11]),
                    Label(Localized("settings.docs.netoworkstate"), DETAIL, image = img[12]),
                ),
            null,
            )
        )
    }

    private fun sectionsForThemes(): List<Section> = listOf(
        Section(
            null,
            listOf(
                "settings.themes.miami.light",
                "settings.themes.miami.dark",
                "settings.themes.vanilla.light",
                "settings.themes.vanilla.dark",
            ).mapIndexed { idx, str -> Label(Localized(str), themeAcc(idx)) },
            null,
        )
    )

    private fun themeAcc(idx: Int): CellViewModel.Accessory {
        return if (selectedThemeIdx() == idx) CHECKMARK else NONE
    }

    fun selectedThemeIdx(): Int {
        var idx = if (interactor.themeId == ThemeId.MIAMI) 0 else 2
        idx += if (interactor.themeVariant == ThemeVariant.DARK) 1 else 0
        return idx
    }

    private fun sectionsForUITweaks(): List<Section> = listOf(
        Section(
            Title(Localized("settings.uitweaks.nft.carousel.title")),
            listOf(
                "settings.uitweaks.nft.carousel.regular",
                "settings.uitweaks.nft.carousel.large"
            ).mapIndexed{ idx, str -> Label(Localized(str), carouselAcc(idx)) },
            null,
        )
    )

    private fun carouselAcc(idx: Int): CellViewModel.Accessory {
        return if (selectedCarouselIdx() == idx) CHECKMARK else NONE
    }

    private fun selectedCarouselIdx(): Int {
        return if (interactor.nftCarouselSize == NFTCarouselSize.REGULAR) 0 else 1
    }

    private fun sectionsForDeveloper(): List<Section> = listOf(
        Section(
            Title("warning this will delete all mnemonics"),
            listOf(Label(Localized("settings.developer.resetKeyStore"), NONE)),
            Footer.Text(
                "Be very CAREFULLY this will delete all mnemonic. Only " +
                "intended for testing and development. If you are not sure " +
                "LEAVE FROM THIS SCREEN NOW! "
            ),
        )
    )
}