package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicnew

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.extensions.annotatedString
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewPresenter
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewPresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewView
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewViewModel
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewViewModel.Section
import com.sonsofcrypto.web3walletcore.modules.mnemonicNew.MnemonicNewViewModel.Section.Item

class MnemonicNewFragment: Fragment(), MnemonicNewView {

    lateinit var presenter: MnemonicNewPresenter
    private val liveData = MutableLiveData<MnemonicNewViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { MnemonicNewScreen(it) }
            }
        }
    }

    override fun update(viewModel: MnemonicNewViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun MnemonicNewScreen(viewModel: MnemonicNewViewModel) {
        W3WScreen(
            navBar = {
                W3WNavigationBar(
                    title = Localized("mnemonic.title.new"),
                    trailingIcon = { W3WNavigationClose { presenter.handle(DidSelectDismiss) } }
                )
             },
            content = { MnemonicNewContent(viewModel) }
        )
    }

    @Composable
    private fun MnemonicNewContent(viewModel: MnemonicNewViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            MnemonicNewContentInfo(viewModel.sections)
            W3WButtonPrimary(
                title = viewModel.cta,
                onClick = { presenter.handle(DidSelectCta) }
            )
        }
    }

    @Composable
    private fun ColumnScope.MnemonicNewContentInfo(viewModel: List<Section>) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .weight(1f),
        ) {
            viewModel.forEach { section ->
                MnemonicNewSectionContent(section)
                section.footer?.let { footer ->
                    W3WSpacerVertical(theme().shapes.padding.half)
                    W3WText(text = footer.annotatedString())
                }
                if (viewModel.last() != section) {
                    W3WSpacerVertical(theme().shapes.padding)
                }
            }
        }
    }

    @Composable
    private fun MnemonicNewSectionContent(viewModel: Section) {
        viewModel.items.forEach { item ->
            when (item) {
                is Item.Mnemonic -> {
                    MnemonicNewMnemonic(item.mnemonic)
                }
                is Item.TextInput -> {
                    W3WMnemonicTextInput(
                        title = item.viewModel.title,
                        value = item.viewModel.value,
                        placeholder = item.viewModel.placeholder,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ).padding(start = theme().shapes.padding),
                        onValueChange = { value -> presenter.handle(DidChangeName(value)) }
                    )
                }
                is Item.Switch -> {
                    W3WMnemonicSwitch(
                        title = item.viewModel.title,
                        onOff = item.viewModel.onOff,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ).padding(theme().shapes.padding),
                        onValueChange = { value -> presenter.handle(DidChangeICouldBackup(value))}
                    )
                }
                is Item.SwitchWithTextInput -> {}
                is Item.SegmentWithTextAndSwitchInput -> {
                    W3WMnemonicSegmentTexAndSwitch(
                        viewModel = item.viewModel,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ),
                        onSegmentChange = { presenter.handle(PassTypeDidChange(it)) },
                        onPasswordChange = { presenter.handle(PasswordDidChange(it)) },
                        onAllowFaceIDChange = { presenter.handle(AllowFaceIdDidChange(it)) }
                    )
                }
            }
        }
    }

    @Composable
    private fun MnemonicNewMnemonic(mnemonic: String) {
        Column(
            modifier = ModifierCardBackground()
                .padding(theme().shapes.padding)
                .heightIn(min = theme().shapes.cellHeight)
        ) {
            W3WText(text = mnemonic)
        }
    }
}