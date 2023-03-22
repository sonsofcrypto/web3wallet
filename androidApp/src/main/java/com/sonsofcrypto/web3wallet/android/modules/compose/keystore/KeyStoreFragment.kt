package com.sonsofcrypto.web3wallet.android.modules.compose.keystore

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStorePresenter
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStorePresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreView
import com.sonsofcrypto.web3walletcore.modules.keyStore.KeyStoreViewModel

class KeyStoreFragment: Fragment(), KeyStoreView {

    lateinit var presenter: KeyStorePresenter
    private val liveData = MutableLiveData<KeyStoreViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { KeyStoreScreen(it) }
            }
        }
    }

    override fun update(viewModel: KeyStoreViewModel) {
        liveData.value = viewModel
    }

    override fun updateTargetView(targetView: KeyStoreViewModel.TransitionTargetView) {}

    @Composable
    private fun KeyStoreScreen(viewModel: KeyStoreViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("wallets")) },
            content = { KeyStoreContent(viewModel) }
        )
    }

    @Composable
    private fun KeyStoreContent(viewModel: KeyStoreViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(
                    bottom = theme().shapes.padding,
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                ),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (viewModel.items.isEmpty()) {
                KeyStoreEmptyListContent()
            } else {
                KeyStoreItemsListContent(viewModel)
            }
            W3WSpacerVertical()
            KeyStoreButtonActions(viewModel.buttons)
        }
    }
    
    @Composable
    private fun ColumnScope.KeyStoreEmptyListContent() {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .weight(1f),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            W3WImage(
                painter = painterResource(id = R.drawable.image_logo)
            )
        }
    }

    @Composable
    private fun ColumnScope.KeyStoreItemsListContent(viewModel: KeyStoreViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .weight(1f)
                .verticalScroll(ScrollState(0)),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            viewModel.items.forEach {
                val idx = viewModel.items.indexOf(it)
                KeyStoreItem(
                    viewModel = it,
                    idx = idx,
                    isSelected = viewModel.selectedIdxs.contains(idx),
                )
                if (viewModel.items.last() != it) { W3WSpacerVertical() }
            }
        }
    }

    @Composable
    private fun KeyStoreItem(
        viewModel: KeyStoreViewModel.Item,
        idx: Int,
        isSelected: Boolean,
    ) {
        Row(
            modifier = ModifierClickable(
                onClick = { presenter.handle(DidSelectKeyStoreItemtAt(idx)) }
            )
                .fillMaxWidth()
                .then(ModifierCardBackground())
                .then(if (isSelected) ModifierBorder() else Modifier)
                .padding(theme().shapes.padding),
            verticalAlignment = Alignment.CenterVertically
        ) {
            W3WText(
                text = (idx + 1).toString(),
                style = theme().fonts.footnote,
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .size(20.dp)
                    .clip(RoundedCornerShape(4.dp))
                    .background(theme().colors.navBarTint)
            )
            W3WSpacerHorizontal(theme().shapes.padding)
            Column(
                modifier = Modifier.weight(1f)
            ) {
                W3WText(text = viewModel.title)
                viewModel.address?.let {
                    W3WText(
                        text = it,
                        style = theme().fonts.footnote,
                        color = theme().colors.textSecondary,
                    )
                }
            }
            W3WSpacerHorizontal(theme().shapes.padding)
            W3WIcon(
                id = R.drawable.icon_settings_24,
                onClick = { presenter.handle(DidSelectAccessory(idx)) }
            )
            W3WSpacerHorizontal(theme().shapes.padding)
            W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24)
        }
    }

    @Composable
    private fun KeyStoreButtonActions(viewModel: KeyStoreViewModel.ButtonSheetViewModel) {
        Column {
            // NOTE: For now we are going to show only the first 2 buttons (create / import)
            val list = viewModel.buttons.take(2)
            list.forEach {
                W3WButtonPrimary(
                    title = it.title,
                    onClick = {
                        presenter.handle(DidSelectButtonAt(viewModel.buttons.indexOf(it)))
                    }
                )
                if (list.last() != it) { W3WSpacerVertical(theme().shapes.padding.half) }
            }
        }
    }
}