package com.sonsofcrypto.web3wallet.android.modules.compose.degen

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.*
import com.sonsofcrypto.web3wallet.android.common.extensions.navigationFragment
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.degen.DegenPresenter
import com.sonsofcrypto.web3walletcore.modules.degen.DegenPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.degen.DegenView
import com.sonsofcrypto.web3walletcore.modules.degen.DegenViewModel

class DegenFragment : Fragment(), DegenView {

    lateinit var presenter: DegenPresenter

    private val liveData = MutableLiveData<DegenViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val systemUiController = rememberSystemUiController()
                systemUiController.setSystemBarsColor(
                    color = theme().colors.navBarBackground
                )

                val viewModel by liveData.observeAsState()
                viewModel?.let { DegenScreen(it) }
            }
        }
    }

    override fun update(viewModel: DegenViewModel) {
        liveData.value = viewModel
    }

    override fun popToRootAndRefresh() {
        navigationFragment?.popToRoot()
        presenter.present()
    }

    @Composable
    private fun DegenScreen(viewModel: DegenViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("degen")) },
            content = { DegenContent(viewModel) }
        )
    }

    @Composable
    private fun DegenContent(viewModel: DegenViewModel) {
        LazyColumn(
            Modifier.padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            items(viewModel.sections.size) { index ->
                DegenSection(viewModel.sections[index])
                if (viewModel.sections.count() - 1 == index) {
                    W3WSpacerVertical()
                }
            }
        }
        W3WSpacerVertical()
    }

    @Composable
    private fun DegenSection(section: DegenViewModel.Section) {
        W3WSpacerVertical()
        when (section) {
            is DegenViewModel.Section.Header -> {
                Text(
                    text = section.title,
                    modifier = Modifier
                        .padding(start = theme().shapes.padding, end = theme().shapes.padding),
                    color = if(section.isEnabled) theme().colors.textPrimary else theme().colors.textSecondary,
                    style = theme().fonts.bodyBold
                )
            }
            is DegenViewModel.Section.Group -> {
                DegenItems(section.items)
                W3WSpacerVertical(height = 4.dp)
            }
        }
    }
    
    @Composable
    private fun DegenItems(items: List<DegenViewModel.Item>) {
        var showUnderConstruction by remember { mutableStateOf(false) }
        Column(
            Modifier
                .clip(RoundedCornerShape(theme().shapes.padding))
                .background(theme().colors.bgPrimary)
                .padding(theme().shapes.padding)
        ) {
            items.forEach {
                DegenItem(item = it) {
                    if (it.isEnabled) {
                        val index = items.indexOf(it)
                        presenter.handle(DegenPresenterEvent.DidSelectCategory(index))
                    } else {
                        showUnderConstruction = true
                    }
                }
                if (items.last() != it) {
                    W3WSpacerVertical(height = 8.dp)
                    W3WDivider()
                    W3WSpacerVertical(height = 8.dp)
                }
            }
        }
        if (showUnderConstruction) {
            W3WDialogUnderConstruction { showUnderConstruction = false }
        }
    }

    @Composable
    private fun DegenItem(item: DegenViewModel.Item, onClick: () -> Unit) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onClick,
                ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Column {
                W3WText(
                    item.title,
                    color = if (item.isEnabled) theme().colors.textPrimary else theme().colors.textSecondary,
                )
                W3WText(
                    item.subtitle,
                    color = theme().colors.textSecondary,
                    style = theme().fonts.subheadline,
                )
            }
            val tint = if (item.isEnabled) theme().colors.textPrimary else theme().colors.textSecondary
            W3WIcon(
                id = R.drawable.icon_keyboard_arrow_right_24,
                colorFilter = ColorFilter.tint(tint)
            )
        }
    }
}
