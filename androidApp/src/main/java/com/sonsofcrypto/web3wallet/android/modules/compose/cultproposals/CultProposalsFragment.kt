package com.sonsofcrypto.web3wallet.android.modules.compose.cultproposals

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
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsPresenter
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsPresenterEvent.SelectProposal
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsView
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsViewModel
import java.text.NumberFormat

class CultProposalsFragment : Fragment(), CultProposalsView {

    lateinit var presenter: CultProposalsPresenter

    private val liveData = MutableLiveData<CultProposalsViewModel>()
    private val formatter = NumberFormat.getInstance()

    init {
        formatter.maximumFractionDigits = 2
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CultProposalsScreen(it) }
            }
        }
    }

    override fun update(viewModel: CultProposalsViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun CultProposalsScreen(viewModel: CultProposalsViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = Localized("cult.proposals.title")) },
            content = { CultProposalsContent(viewModel) }
        )
    }

    @Composable
    private fun CultProposalsContent(viewModel: CultProposalsViewModel) {
        when (viewModel) {
            is CultProposalsViewModel.Loading -> {
                W3WLoadingInMaxSizeContainer()
            }
            is CultProposalsViewModel.Loaded -> {
                viewModel.sections.firstOrNull()?.let { CultProposalsLoaded(it) }
            }
            is CultProposalsViewModel.Error -> {
                W3WLoadingInMaxSizeContainer()
            }
        }
    }

    @Composable
    private fun CultProposalsLoaded(section: CultProposalsViewModel.Section) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(30.dp + theme().shapes.padding)
                    .background(theme().colors.navBarBackground),
                verticalAlignment = Alignment.Top,
                horizontalArrangement = Arrangement.Center,
            ) {
                CultTabSelector()
            }
            when (section) {
                is CultProposalsViewModel.Section.Pending -> {
                    CultProposalsList(section.title, section.items, section.footer)
                }
                is CultProposalsViewModel.Section.Closed -> {
                    CultProposalsList(section.title, section.items, section.footer)
                }
            }
        }
    }

    @Composable
    private fun CultTabSelector() {
        var pendingSelected by remember { mutableStateOf(true) }
        Box(
            modifier = Modifier
                .width(200.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(theme().colors.segmentedControlBackground),
            contentAlignment = Alignment.Center
        ) {
            val bgColor = theme().colors.segmentedControlBackground
            val bgSelectedColor = theme().colors.segmentedControlBackgroundSelected
            val textColor = theme().colors.segmentedControlText
            val textSelectedColor = theme().colors.segmentedControlTextSelected
            val onPendingSelected = {
                pendingSelected = true
                presenter.handle(CultProposalsPresenterEvent.SelectPendingProposals)
            }
            val onClosedSelected = {
                pendingSelected = false
                presenter.handle(CultProposalsPresenterEvent.SelectClosedProposals)
            }
            W3WText(
                text = Localized("cult.proposals.segmentedControl.pending"),
                modifier = ModifierClickable(onClick = onPendingSelected)
                    .width(100.dp)
                    .height(30.dp)
                    .background(if (pendingSelected) bgSelectedColor else bgColor)
                    .padding(start = 8.dp, top = 4.dp, end = 8.dp)
                    .align(Alignment.CenterStart),
                color = if (pendingSelected) textSelectedColor else textColor,
                textAlign = TextAlign.Center,
                style = theme().fonts.footnote,
            )
            W3WText(
                text = Localized("cult.proposals.segmentedControl.closed"),
                modifier = ModifierClickable(onClick = onClosedSelected)
                    .width(100.dp)
                    .height(30.dp)
                    .background(if (!pendingSelected) bgSelectedColor else bgColor)
                    .padding(start = 8.dp, top = 4.dp, end = 8.dp)
                    .align(Alignment.CenterEnd),
                color = if (!pendingSelected) textSelectedColor else textColor,
                textAlign = TextAlign.Center,
                style = theme().fonts.footnote,
            )
        }
    }

    @Composable
    private fun CultProposalsList(
        title: String,
        items: List<CultProposalsViewModel.Item>,
        footer: CultProposalsViewModel.Footer,
    ) {
        LazyColumn(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            items(if(items.isEmpty()) 1 else items.size) { index ->
                if (index == 0) {
                    W3WSpacerVertical(height = 8.dp)
                    Title3BoldText(text = title, textAlign = TextAlign.Start)
                }
                if (items.isNotEmpty()) {
                    W3WSpacerVertical(height = 8.dp)
                    CultProposalItem(item = items[index]) {
                        presenter.handle(SelectProposal(index))
                    }
                    W3WSpacerVertical(height = 8.dp)
                }
                if (index == items.size - 1 || items.isEmpty()) {
                    Title3BoldText(text = footer.text, textAlign = TextAlign.Center)
                }
            }
        }
    }

    @Composable
    private fun Title3BoldText(text: String, textAlign: TextAlign) {
        W3WText(
            text,
            color = theme().colors.textPrimary,
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
                .fillMaxWidth(),
            textAlign = textAlign,
            style = theme().fonts.title3Bold,
        )
    }

    @Composable
    private fun CultProposalItem(
        item: CultProposalsViewModel.Item,
        onClick: () -> Unit,
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(theme().shapes.padding))
                .background(theme().colors.bgPrimary)
                .padding(theme().shapes.padding)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onClick,
                )
        ) {
            W3WText(
                item.title,
                modifier = Modifier.fillMaxWidth(),
                style = theme().fonts.bodyBold,
                overflow = TextOverflow.Ellipsis,
                //maxLines = 1,
            )
            W3WSpacerVertical()
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                CultProposalClosedResults(item)
                W3WIcon(id = R.drawable.icon_keyboard_arrow_right_24)
            }
            W3WSpacerVertical()
            W3WText(
                item.stateName,
                modifier = Modifier.fillMaxWidth(),
                style = theme().fonts.calloutBold,
                textAlign = TextAlign.Center,
            )
            val totalVotes = formatter.format(item.approved.total + item.rejected.total)
            W3WText(
                Localized("cult.proposals.closed.totalVotes", totalVotes),
                modifier = Modifier.fillMaxWidth(),
                style = theme().fonts.callout,
                textAlign = TextAlign.Center,
            )

        }
    }

    @Composable
    private fun CultProposalClosedResults(
        item: CultProposalsViewModel.Item
    ) {
        Column(
            Modifier.fillMaxWidth(0.93f)
        ) {
            CultProposalVotes(vote = item.approved, color = theme().colors.priceUp)
            W3WSpacerVertical(height = 8.dp)
            CultProposalVotes(vote = item.rejected, color = theme().colors.priceDown)
        }
    }

    @Composable
    fun CultProposalVotes(
        vote: CultProposalsViewModel.Vote,
        color: Color
    ) {
        Row(
            Modifier
                .fillMaxWidth()
                .height(30.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(theme().shapes.cornerRadiusSmall))
                    .background(theme().colors.bgPrimary),
            ) {
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(theme().shapes.cornerRadiusSmall))
                        .fillMaxWidth(vote.value.toFloat())
                        .fillMaxHeight()
                        .background(color),
                )
                W3WSpacerVertical()
                W3WText(
                    vote.name + " " + formatter.format(vote.value * 100) + "%",
                    modifier = Modifier
                        .fillMaxWidth()
                        .align(Alignment.Center)
                        .padding(start = 8.dp),
                    style = theme().fonts.footnote,
                )
            }
            W3WSpacerHorizontal()
            val approvedVotes = formatter.format(vote.total)
            W3WText(
                approvedVotes,
                modifier = Modifier.weight(1f),
                style = theme().fonts.footnote,
            )
        }
    }
}

private fun CultProposalsViewModel.Section.isPending(): Boolean = when (this) {
    is CultProposalsViewModel.Section.Pending -> true
    is CultProposalsViewModel.Section.Closed -> false
}

private fun CultProposalsViewModel.Section.isClosed(): Boolean = when (this) {
    is CultProposalsViewModel.Section.Pending -> false
    is CultProposalsViewModel.Section.Closed -> true
}
