package com.sonsofcrypto.web3wallet.android.modules.compose.networks

import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.drawableId
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksPresenter
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksView
import com.sonsofcrypto.web3walletcore.modules.networks.NetworksViewModel

class NetworksFragment: Fragment(), NetworksView {

    lateinit var presenter: NetworksPresenter
    private var liveData = MutableLiveData<NetworksViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()

        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { NetworksScreen(it) }
            }
        }
    }

    override fun update(viewModel: NetworksViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun NetworksScreen(viewModel: NetworksViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("networks")) },
            content = { NetworksContent(viewModel) }
        )
    }

    @Composable
    private fun NetworksContent(viewModel: NetworksViewModel) {
        var showUnderConstruction by remember { mutableStateOf(false) }
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
                .verticalScroll(ScrollState(0))
        ) {
            W3WText(text = viewModel.header)
            W3WSpacerVertical()
            viewModel.sections.forEach {
                NetworksSection(
                    viewModel = it,
                    onNetworkClick = { chainId ->
                        presenter.handle(NetworksPresenterEvent.DidSelectNetwork(chainId))
                    },
                    onNetworkSwitchClick = { chainId, isOn ->
                        presenter.handle(NetworksPresenterEvent.DidSwitchNetwork(chainId, isOn))
                    },
                    onSettingsClick = { showUnderConstruction = true }
                )
                if (viewModel.sections.last() != it) { W3WSpacerVertical(theme().shapes.padding) }
            }
        }
        if (showUnderConstruction) { W3WDialogUnderConstruction { showUnderConstruction = false } }
    }

    @Composable
    private fun NetworksSection(
        viewModel: NetworksViewModel.Section,
        onNetworkClick: (UInt) -> Unit,
        onNetworkSwitchClick: (UInt, Boolean) -> Unit,
        onSettingsClick: (UInt) -> Unit,
    ) {
        Column {
            W3WText(
                text = viewModel.header,
                style = theme().fonts.title3,
            )
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WDivider()
            W3WSpacerVertical(theme().shapes.padding)
            viewModel.networks.forEach {
                NetworkItem(it, onNetworkClick, onNetworkSwitchClick, onSettingsClick)
                if (viewModel.networks.last() != it) { W3WSpacerVertical(theme().shapes.padding) }
            }
        }
    }

    @Composable
    private fun NetworkItem(
        viewModel: NetworksViewModel.Network,
        onNetworkClick: (UInt) -> Unit,
        onNetworkSwitchClick: (UInt, Boolean) -> Unit,
        onSettingsClick: (UInt) -> Unit,
    ) {
        Row(
            modifier = ModifierCardBackground()
                .padding(theme().shapes.padding)
                .then(
                    ModifierClickable(onClick = { onNetworkClick(viewModel.chainId) })
                ),
            verticalAlignment = Alignment.Top
        ) {
            W3WIcon(
                id = drawableId(
                    name = viewModel.imageName,
                    defaultId = R.drawable.icon_default_currency_24,
                ),
                modifier = Modifier.clip(RoundedCornerShape(24.dp / 2))
            )
            W3WSpacerHorizontal(theme().shapes.padding)
            Column {
                NetworkIconNameAndSettings(viewModel, onNetworkSwitchClick, onSettingsClick)
                W3WSpacerVertical(theme().shapes.padding.half)
                W3WDivider()
                W3WSpacerVertical(theme().shapes.padding.half)
                NetworkIconConnection(viewModel)
            }
        }
    }

    @Composable
    fun NetworkIconNameAndSettings(
        viewModel: NetworksViewModel.Network,
        onNetworkSwitchClick: (UInt, Boolean) -> Unit,
        onSettingsClick: (UInt) -> Unit,
    ) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            W3WText(
                text = viewModel.name,
                modifier = Modifier.weight(1f),
            )
            W3WIcon(
                id = R.drawable.icon_settings_24,
                onClick = { onSettingsClick(viewModel.chainId) },
            )
            W3WSpacerHorizontal(theme().shapes.padding.half)
            W3WSwitch(
                checked = viewModel.connected,
                onCheckedChange = { onNetworkSwitchClick(viewModel.chainId, !viewModel.connected) },
            )
        }
    }

    @Composable
    fun NetworkIconConnection(viewModel: NetworksViewModel.Network) {
        Row {
            W3WText(
                text = Localized("networks.cell.connection"),
                style = theme().fonts.subheadline,
                color = theme().colors.textSecondary,
            )
            W3WSpacerHorizontal(theme().shapes.padding.half.half)
            W3WText(
                text = viewModel.connectionType,
                style = theme().fonts.subheadlineBold,
            )
        }
    }
}