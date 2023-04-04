package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicimport

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.extensions.annotatedString
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.extensions.threeQuarter
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportPresenter
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportPresenterEvent.DidSelectCta
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportPresenterEvent.MnemonicChanged
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportView
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportViewModel
import com.sonsofcrypto.web3walletcore.modules.mnemonicImport.MnemonicImportViewModel.Section.Mnemonic

class MnemonicImportFragment: Fragment(), MnemonicImportView {

    lateinit var presenter: MnemonicImportPresenter
    private val liveData = MutableLiveData<MnemonicImportViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply { 
            setContent { 
                val viewModel by liveData.observeAsState()
                viewModel?.let { MnemonicImportScreen(it) }
            }
        }
    }
    
    override fun update(viewModel: MnemonicImportViewModel) {
        liveData.value = viewModel
    }
    
    @Composable
    private fun MnemonicImportScreen(viewModel: MnemonicImportViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("mnemonic.title.import")) },
            content = { MnemonicImportContent(viewModel) }
        )
    }

    @Composable
    private fun MnemonicImportContent(viewModel: MnemonicImportViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            MnemonicImportContentInfo(viewModel.sections)
            W3WButtonPrimary(
                title = viewModel.cta,
                onClick = { presenter.handle(DidSelectCta) }
            )
        }
    }

    @Composable
    private fun ColumnScope.MnemonicImportContentInfo(viewModel: List<MnemonicImportViewModel.Section>) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .weight(1f),
        ) {
            viewModel.forEach { section ->
                MnemonicImportSectionContent(section)
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
    private fun MnemonicImportSectionContent(viewModel: MnemonicImportViewModel.Section) {
        viewModel.items.forEach { item ->
            when (item) {
                is MnemonicImportViewModel.Section.Item.Mnemonic -> {
                    MnemonicImportMnemonic(item.mnemonic)
                }
                is MnemonicImportViewModel.Section.Item.TextInput -> {
                    W3WMnemonicTextInput(
                        title = item.viewModel.title,
                        value = item.viewModel.value,
                        placeholder = item.viewModel.placeholder,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ).padding(start = theme().shapes.padding),
                        onValueChange = { value -> presenter.handle(
                            MnemonicImportPresenterEvent.DidChangeName(
                                value
                            )
                        ) }
                    )
                }
                is MnemonicImportViewModel.Section.Item.Switch -> {
                    W3WMnemonicSwitch(
                        title = item.viewModel.title,
                        onOff = item.viewModel.onOff,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ).padding(theme().shapes.padding),
                        onValueChange = { value -> presenter.handle(
                            MnemonicImportPresenterEvent.DidChangeICouldBackup(
                                value
                            )
                        )}
                    )
                }
                is MnemonicImportViewModel.Section.Item.SwitchWithTextInput -> {}
                is MnemonicImportViewModel.Section.Item.SegmentWithTextAndSwitchInput -> {
                    W3WMnemonicSegmentTexAndSwitch(
                        viewModel = item.viewModel,
                        modifier = ModifierDynamicBg(
                            viewModel.items.indexOf(item),
                            viewModel.items.count()
                        ),
                        onSegmentChange = { presenter.handle(
                            MnemonicImportPresenterEvent.PassTypeDidChange(
                                it
                            )
                        ) },
                        onPasswordChange = { presenter.handle(
                            MnemonicImportPresenterEvent.PasswordDidChange(
                                it
                            )
                        ) },
                        onAllowFaceIDChange = { presenter.handle(
                            MnemonicImportPresenterEvent.AllowFaceIdDidChange(
                                it
                            )
                        ) }
                    )
                }
            }
        }
    }

    @Composable
    private fun MnemonicImportMnemonic(viewModel: Mnemonic) {
        Column(
            modifier = ModifierCardBackground()
                .height(110.dp)
                .then(ModifierMnemonicValidationBorder(viewModel.wordsInfo, viewModel.isValid))
        ) {
            var value by remember { mutableStateOf(TextFieldValue("")) }
            W3WTextField(
                value = value,
                onValueChange = {
                    value = it
                    presenter.handle(MnemonicChanged(value.text, value.selection.start))
                },
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .height(theme().shapes.cellHeight),
                singleLine = false,
                minLines = 3,
                maxLines = 3,
            )
            W3WMnemonicError(
                viewModel = viewModel.wordsInfo,
                isValid = viewModel.isValid ?: true
            )?.let { text ->
                W3WText(
                    text = text,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(
                            start = theme().shapes.padding,
                            end = theme().shapes.padding,
                            bottom = theme().shapes.padding.threeQuarter,
                        ),
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}