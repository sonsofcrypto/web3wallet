package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicupdate

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.extensions.annotatedString
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenter
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdatePresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateView
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateViewModel
import com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate.MnemonicUpdateViewModel.Section

class MnemonicUpdateFragment: Fragment(), MnemonicUpdateView {

    lateinit var presenter: MnemonicUpdatePresenter
    private val liveData = MutableLiveData<MnemonicUpdateViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { MnemonicUpdateScreen(it) }
            }
        }
    }

    override fun update(viewModel: MnemonicUpdateViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun MnemonicUpdateScreen(viewModel: MnemonicUpdateViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("mnemonic.title.update")) },
            content = { MnemonicUpdateContent(viewModel) }
        )
    }

    @Composable
    private fun MnemonicUpdateContent(viewModel: MnemonicUpdateViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            MnemonicUpdateContentInfo(viewModel.sections)
            W3WButtonPrimary(
                title = viewModel.cta,
                onClick = { presenter.handle(Update) }
            )
        }
    }

    @Composable
    private fun ColumnScope.MnemonicUpdateContentInfo(viewModel: List<Section>) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .weight(1f),
        ) {
            viewModel.forEach { section ->
                MnemonicUpdateSectionContent(section)
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
    private fun MnemonicUpdateSectionContent(viewModel: Section) {
        viewModel.items.forEach { item ->
            when (item) {
                is Section.Item.Mnemonic -> {
                    MnemonicUpdateMnemonic(item.mnemonic)
                }
                is Section.Item.TextInput -> {
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
                is Section.Item.Switch -> {
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
                is Section.Item.SwitchWithTextInput -> {}
                is Section.Item.SegmentWithTextAndSwitchInput -> {}
                is Section.Item.Delete -> {
                    W3WButtonPrimary(
                        title = item.title,
                        isDestructive = true,
                        onClick = { presenter.handle(ConfirmDelete) }
                    )
                }
            }
        }
    }

    @Composable
    private fun MnemonicUpdateMnemonic(mnemonic: String) {
        var showMnemonic by remember { mutableStateOf(false) }
        if (showMnemonic) {
            MnemonicUpdateMnemonicPlain(mnemonic = mnemonic) {
                // TODO: Implement copy action since this should have an expiration time like ios
//                App.copyToClipboard(mnemonic)
//                Toast.makeText(
//                    context, Localized("mnemonic.pasteboard.generic"), Toast.LENGTH_LONG
//                ).show()
                showMnemonic = false
            }
        } else {
            MnemonicUpdateMnemonicHidden {
                showMnemonic = true
            }
        }
    }

    @Composable
    private fun MnemonicUpdateMnemonicPlain(mnemonic: String, onClick: () -> Unit) {
        Column(
            modifier = ModifierCardBackground()
                .fillMaxWidth()
                .padding(theme().shapes.padding)
                .heightIn(min = theme().shapes.cellHeight)
                .then(ModifierClickable(onClick = onClick))
        ) {
            W3WText(text = mnemonic)
        }
    }

    @Composable
    private fun MnemonicUpdateMnemonicHidden(onClick: () -> Unit) {
        Column(
            modifier = ModifierCardBackground()
                .background(theme().colors.bgPrimary)
                .fillMaxWidth()
                .padding(theme().shapes.padding)
                .heightIn(min = theme().shapes.cellHeight)
                .then(ModifierClickable(onClick = onClick)),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WText(text = Localized("mnemonic.tapToReveal"))
        }
    }
}