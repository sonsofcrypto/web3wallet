package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.DESTRUCTIVE
import com.sonsofcrypto.web3walletcore.common.viewModels.ButtonViewModel.Kind.SECONDARY
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CellViewModel.Text
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.BarButton
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Footer.HighlightWords
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Screen
import com.sonsofcrypto.web3walletcore.common.viewModels.CollectionViewModel.Section
import com.sonsofcrypto.web3walletcore.common.viewModels.ImageMedia.SysName
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.alert.AlertWireframeContext
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeContext
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.AlertAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CTAAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.ConfirmDelete
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CopyAccountAddress
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetICouldBackup
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetName
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.CopyMnemonic
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.RightBarButtonAction
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetAccountHidden
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.SetAccountName
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.ViewPrivKey
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Alert
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Authenticate
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateWireframeDestination.Dismiss

sealed class MnemonicUpdatePresenterEvent {
    data class SetName(val name: String): MnemonicUpdatePresenterEvent()
    data class SetICouldBackup(val onOff: Boolean): MnemonicUpdatePresenterEvent()
    object CopyMnemonic: MnemonicUpdatePresenterEvent()
    object Dismiss: MnemonicUpdatePresenterEvent()
    object ConfirmDelete: MnemonicUpdatePresenterEvent()
    data class AlertAction(val idx: Int, val text: String?): MnemonicUpdatePresenterEvent()
    data class SetAccountName(val name: String, val idx: Int): MnemonicUpdatePresenterEvent()
    data class SetAccountHidden(val hidden: Boolean, val idx: Int): MnemonicUpdatePresenterEvent()
    data class CopyAccountAddress(val idx: Int): MnemonicUpdatePresenterEvent()
    data class ViewPrivKey(val idx: Int): MnemonicUpdatePresenterEvent()
    data class RightBarButtonAction(val idx: Int): MnemonicUpdatePresenterEvent()
    data class CTAAction(val idx: Int): MnemonicUpdatePresenterEvent()
}

interface MnemonicUpdatePresenter {
    fun present()
    fun handle(event: MnemonicUpdatePresenterEvent)
}

class DefaultMnemonicUpdatePresenter(
    private val view: WeakRef<MnemonicUpdateView>,
    private val wireframe: MnemonicUpdateWireframe,
    private val interactor: MnemonicUpdateInteractor,
    private val context: MnemonicUpdateWireframeContext,
): MnemonicUpdatePresenter {
    private var ctaTapped = false

    override fun present() {
        updateView()
        wireframe.navigate(Authenticate(authenticateContext()))
    }

    override fun handle(event: MnemonicUpdatePresenterEvent) =  when (event) {
        is SetName -> interactor.name = event.name
        is SetICouldBackup -> interactor.iCloudSecretStorage = event.onOff
        is CopyMnemonic -> interactor.pasteToClipboard(
            interactor.mnemonic().trim()
        )
        is MnemonicUpdatePresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        is ConfirmDelete -> wireframe.navigate(
            Alert(deleteConfirmationAlertContext())
        )
        is SetAccountName -> print("SetAccountName")
        is SetAccountHidden -> print("SetAccountHidden")
        is CopyAccountAddress -> print("CopyAccountAddress")
        is ViewPrivKey -> print("ViewPrivKey")
        is AlertAction -> print("AlertAction")
        is RightBarButtonAction -> {
            println("Right bar button action ${event.idx}")
        }
        is CTAAction -> {
            when (event.idx) {
                0 -> print("Add account") // interactor.addAccount()
                1 -> handleDelete()
                2 -> handleUpdate()
            }
            updateView()
        }
    }

    private fun handleDelete() {
        interactor.delete()
        context.deleteHandler()
        wireframe.navigate(Dismiss)
    }

    private fun handleUpdate() {
        ctaTapped = true
        if (!isValidForm) return updateView()
        val updatedItem = interactor.update()
            ?: return wireframe.navigate(Alert(errorAlertContext()))
        context.updateHandler(updatedItem)
        wireframe.navigate(Dismiss)
    }

    private fun authenticateContext(): AuthenticateWireframeContext
        = AuthenticateWireframeContext(
            Localized("authenticate.title.unlock"),
            context.signerStoreItem,
        ) { auth, error ->
            if (auth != null && error == null) {
                interactor.setup(
                    context.signerStoreItem,
                    auth.password,
                    auth.salt
                )
                if (interactor.mnemonic().isEmpty()) wireframe.navigate(Dismiss)
                else updateView()
            } else {
                wireframe.navigate(Dismiss)
            }
        }

    private fun errorAlertContext(): AlertWireframeContext
        = AlertWireframeContext(
            Localized("mnemonic.update.failed.alert.title"),
            null,
            Localized("mnemonic.update.failed.alert.message"),
            listOf(
                AlertWireframeContext.Action(
                    Localized("ok"),
                    AlertWireframeContext.Action.Type.PRIMARY
                )
            ),
            null,
            350.toDouble()
        )

    private fun deleteConfirmationAlertContext(): AlertWireframeContext
        = AlertWireframeContext(
            Localized("alert.deleteWallet.title"),
            null,
            Localized("alert.deleteWallet.message"),
            listOf(
                AlertWireframeContext.Action(
                    Localized("alert.deleteWallet.action.confirm"),
                    AlertWireframeContext.Action.Type.DESTRUCTIVE
                ),
                AlertWireframeContext.Action(
                    Localized("cancel"),
                    AlertWireframeContext.Action.Type.SECONDARY
                )
            ),
            { idx -> if (idx == 0) handleDelete() },
            350.toDouble()
        )

    private fun updateView() {
        view.get()?.update(viewModel())
    }

    private fun viewModel(): Screen = Screen(
        Localized("mnemonicConfirmation.title"),
        listOf(
            mnemonicSection(),
            optionsSection(),
            buttonsSection(),
        ) + accountsSections(),
        listOf(
            BarButton(
                null,
                SysName(if (interactor.showHidden) "eye.slash" else "eye"),
                interactor.hiddenAccountsCount() == 0
            ),
        ),
        ctaItems = listOf(
            ButtonViewModel(Localized("mnemonic.cta.account"), SECONDARY),
            ButtonViewModel(Localized("mnemonic.cta.update")),
        ),
    )

    private fun mnemonicSection(): Section = Section(
        null,
        listOf(Text(interactor.mnemonic())),
        HighlightWords(
            Localized("mnemonic.footer"),
            listOf(
                Localized("mnemonic.footerHighlightWord0"),
                Localized("mnemonic.footerHighlightWord1"),
            )
        ),
    )

    private fun optionsSection(): Section = Section(
        null,
        listOf(
            CellViewModel.TextInput(
                Localized("mnemonic.name.title"),
                interactor.name,
                Localized("mnemonic.name.placeholder"),
            ),
            CellViewModel.Switch(
                Localized("mnemonic.iCould.title"),
                interactor.iCloudSecretStorage,
            )
        ),
        null
    )

    private fun buttonsSection(): Section = Section(
        null,
        listOf(
            CellViewModel.Button(
                ButtonViewModel(Localized("mnemonic.copy.address"), SECONDARY)
            ),
            CellViewModel.Button(
                ButtonViewModel(Localized("mnemonic.cta.delete"), DESTRUCTIVE),
            ),
        ),
        null
    )

    @OptIn(ExperimentalStdlibApi::class)
    private fun accountsSections(): List<Section>
        = if (interactor.accountsCount() <= 1)
            emptyList()
        else (0..<interactor.accountsCount()).map {
            Section(
                CollectionViewModel.Header.Title(
                    "Account ${interactor.absoluteAccountIdx(it)}",
                    interactor.accountDerivationPath(it)
                ),
                listOf(
                    CellViewModel.KeyValueList(
                        listOf(
                            CellViewModel.KeyValueList.Item(
                                Localized("mnemonic.account.name"),
                                interactor.accountName(it),
                                Localized("mnemonic.account.name.placeholder"),
                            ),
                            CellViewModel.KeyValueList.Item(
                                Localized("mnemonic.copy.address"),
                                Localized("mnemonic.view.privKey"),
                                interactor.accountAddress(it),
                            ),
                        ),
                        mapOf("isHidden" to interactor.accountIsHidden(it))
                    )
                ),
                CollectionViewModel.Footer.Text(interactor.accountAddress(it)),
            )
        }

    private val isValidForm: Boolean get() = passwordErrorMessage == null

    private val passwordErrorMessage: String? get() {
        if (!ctaTapped) return null
        if (interactor.name.isEmpty()) { return Localized("mnemonic.error.invalid.name") }
        return null
    }
}
