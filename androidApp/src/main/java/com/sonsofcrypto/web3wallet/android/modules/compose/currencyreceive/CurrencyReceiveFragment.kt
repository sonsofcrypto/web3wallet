package com.sonsofcrypto.web3wallet.android.modules.compose.currencyreceive

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.modifier.modifierLocalConsumer
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceivePresenter
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveView
import com.sonsofcrypto.web3walletcore.modules.currencyReceive.CurrencyReceiveViewModel

class CurrencyReceiveFragment: Fragment(), CurrencyReceiveView {

    lateinit var presenter: CurrencyReceivePresenter
    private val liveData = MutableLiveData<CurrencyReceiveViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CurrencyReceiveScreen(viewModel = it) }
            }
        }
    }

    override fun update(viewModel: CurrencyReceiveViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun CurrencyReceiveScreen(viewModel: CurrencyReceiveViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { CurrencyReceiveContent(viewModel) }
        )
    }

    @Composable
    private fun CurrencyReceiveContent(viewModel: CurrencyReceiveViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(ScrollState(0))
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            QRCodeView(viewModel)
            W3WSpacerVertical()
            W3WText(
                text = viewModel.disclaimer,
                modifier = Modifier
                    .padding(start = theme().shapes.padding, end = theme().shapes.padding),
                textAlign = TextAlign.Center,
            )
            W3WSpacerVertical()
            ActionsView()
        }
    }

    @Composable
    private fun QRCodeView(viewModel: CurrencyReceiveViewModel) {
        Column(
            modifier = CardBackgroundModifier().fillMaxWidth().height(200.dp),
        ) {

        }
    }

    @Composable
    private fun ActionsView() {
        Row {
            W3WButtonSquare(
                iconId = R.drawable.icon_copy_24,
                title = Localized("currencyReceive.action.copy")
            ) {
                println("Copy to clipboard")
            }
            W3WSpacerHorizontal(theme().shapes.padding * 2)
            W3WButtonSquare(
                iconId = R.drawable.icon_ios_share_24,
                title = Localized("currencyReceive.action.share")
            ) {
                println("Copy to clipboard")
            }
        }
    }
}