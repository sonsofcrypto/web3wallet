package com.sonsofcrypto.web3wallet.android.modules.compose.improvementproposal

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.W3WButtonPrimary
import com.sonsofcrypto.web3wallet.android.common.ui.W3WCardWithTitle
import com.sonsofcrypto.web3wallet.android.common.ui.W3WImage
import com.sonsofcrypto.web3wallet.android.common.ui.W3WNavigationBack
import com.sonsofcrypto.web3wallet.android.common.ui.W3WNavigationBar
import com.sonsofcrypto.web3wallet.android.common.ui.W3WNavigationClose
import com.sonsofcrypto.web3wallet.android.common.ui.W3WScreen
import com.sonsofcrypto.web3wallet.android.common.ui.W3WSpacerVertical
import com.sonsofcrypto.web3wallet.android.common.ui.W3WText
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenter
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenterEvent.Back
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenterEvent.Dismiss
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalView
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalViewModel

class ImprovementProposalFragment: Fragment(), ImprovementProposalView {

    lateinit var presenter: ImprovementProposalPresenter

    private val liveData = MutableLiveData<ImprovementProposalViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { ImprovementProposalScreen(viewModel = it) }
            }
        }
    }

    override fun update(viewModel: ImprovementProposalViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun ImprovementProposalScreen(viewModel: ImprovementProposalViewModel) {
        W3WScreen(
            navBar = {
                W3WNavigationBar(
                    title = viewModel.name,
                    leadingIcon = { W3WNavigationBack { presenter.handle(Back) } },
                    trailingIcon = { W3WNavigationClose { presenter.handle(Dismiss) } }
                )
             },
            content = { ImprovementProposalContent(viewModel) }
        )
    }

    @Composable
    private fun ImprovementProposalContent(viewModel: ImprovementProposalViewModel) {
        Column(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
                .verticalScroll(ScrollState(0)),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            W3WSpacerVertical()
            ImprovementProposalStatus(viewModel.status)
            W3WSpacerVertical()
            W3WImage(
                url = viewModel.imageUrl,
                modifier = Modifier.aspectRatio(16f / 9f),
                contentDescription = viewModel.name,
            )
            W3WSpacerVertical()
            W3WCardWithTitle(
                title = Localized("proposal.summary.header"),
                content = { ImprovementProposalSummaryContent(viewModel.body) }
            )
            W3WSpacerVertical()
            W3WButtonPrimary(
                title = Localized("proposal.button.vote"),
            ) {
                presenter.handle(ImprovementProposalPresenterEvent.Vote)
            }
            W3WSpacerVertical()
        }
    }

    @Composable
    private fun ImprovementProposalStatus(value: String) {
        Box(
            modifier = Modifier
                .height(32.dp)
                .width(IntrinsicSize.Max)
                .clip(RoundedCornerShape(8.dp))
                .background(theme().colors.navBarTint),
            contentAlignment = Alignment.Center
        ) {
            W3WText(
                value,
                Modifier
                    .padding(start = 8.dp, top = 4.dp, end = 8.dp, bottom = 4.dp),
                style = theme().fonts.headline
            )
        }
    }

    @Composable
    private fun ImprovementProposalSummaryContent(viewModel: String) {
        W3WText(
            viewModel,
            style = theme().fonts.subheadline,
        )
    }
}