package com.sonsofcrypto.web3wallet.android.modules.compose.settings

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsPresenter
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsPresenterEvent.Select
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsView
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsViewModel
import com.sonsofcrypto.web3walletcore.modules.settings.SettingsViewModel.Section.Footer.Alignment.LEFT

class SettingsFragment: Fragment(), SettingsView {

    lateinit var presenter: SettingsPresenter
    private val liveData = MutableLiveData<SettingsViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { SettingsScreen(it) }
            }
        }
    }

    override fun update(viewModel: SettingsViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun SettingsScreen(viewModel: SettingsViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { SettingsContent(viewModel) }
        )
    }

    @Composable
    private fun SettingsContent(viewModel: SettingsViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                )
                .verticalScroll(ScrollState(0))
        ) {
            W3WSpacerVertical()
            viewModel.sections.forEach {
                SettingsSection(it, viewModel.sections.indexOf(it))
                if (viewModel.sections.last() != it) { W3WSpacerVertical() }
            }
            W3WSpacerVertical()
        }
    }

    @Composable
    private fun SettingsSection(
        viewModel: SettingsViewModel.Section,
        sectionIdx: Int,
    ) {
        viewModel.header?.let {
            W3WText(
                text = it,
                style = theme().fonts.bodyBold
            )
            W3WSpacerVertical()
        }
        SettingsItems(viewModel.items, sectionIdx)
        viewModel.footer?.let {
            W3WSpacerVertical()
            W3WText(
                text = it.title,
                textAlign = if (it.alignment == LEFT) TextAlign.Left else TextAlign.Center,
                color = theme().colors.textSecondary,
                style = theme().fonts.subheadline
            )
        }
    }

    @Composable
    private fun SettingsItems(
        viewModel: List<SettingsViewModel.Section.Item>,
        sectionIdx: Int,
    ) {
        Column(
            modifier = ModifierCardBackground()
                .padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                )
        ) {
            viewModel.forEach {
                SettingsItem(it) {
                    presenter.handle(Select(sectionIdx, viewModel.indexOf(it)))
                }
                if (viewModel.last() != it) { W3WDivider() }
            }
        }
    }

    @Composable
    private fun SettingsItem(
        viewModel: SettingsViewModel.Section.Item,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = ModifierClickable(onClick = onClick)
                .fillMaxWidth()
                .padding(
                    top = theme().shapes.padding,
                    bottom = theme().shapes.padding,
                )
        ) {
            W3WText(
                text = viewModel.title,
                modifier = Modifier.weight(1f)
            )
            W3WSpacerHorizontal()
            if (viewModel.isAction && viewModel.isSelected == true) {
                W3WIcon(id = R.drawable.icon_check_24)
            } else if (!viewModel.isAction) {
                W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24)
            }
        }
    }
}