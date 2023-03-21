package com.sonsofcrypto.web3wallet.android.modules.compose.mnemonicconfirmation

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
import com.sonsofcrypto.web3wallet.android.common.extensions.threeQuarter
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationPresenter
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationPresenterEvent.Confirm
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationPresenterEvent.MnemonicChanged
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationView
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationViewModel

class MnemonicConfirmationFragment: Fragment(), MnemonicConfirmationView {

    lateinit var presenter: MnemonicConfirmationPresenter
    private val liveData = MutableLiveData<MnemonicConfirmationViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent { 
                val viewModel by liveData.observeAsState()
                viewModel?.let { MnemonicConfirmationScreen(it) }
            }
        }
    }

    override fun update(viewModel: MnemonicConfirmationViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun MnemonicConfirmationScreen(viewModel: MnemonicConfirmationViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("mnemonicConfirmation.title")) },
            content = { MnemonicConfirmationContent(viewModel) }
        )
    }

    @Composable
    private fun MnemonicConfirmationContent(viewModel: MnemonicConfirmationViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            W3WText(text = Localized("mnemonicConfirmation.confirm.wallet"))
            W3WSpacerVertical()
            MnemonicConfirmationMnemonic(viewModel)
            W3WSpacerVertical()
            val trailing = if (viewModel.isValid == true) ".congratulations" else ""
            W3WButtonPrimary(
                title = Localized("mnemonicConfirmation.cta${trailing}"),
                onClick = { presenter.handle(Confirm) }
            )
        }
    }

    @Composable
    private fun MnemonicConfirmationMnemonic(viewModel: MnemonicConfirmationViewModel) {
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
                isValid = viewModel.isValid ?: true,
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