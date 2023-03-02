package com.sonsofcrypto.web3wallet.android.modules.cultproposal

import android.os.Bundle
import android.view.View
import android.widget.LinearLayout.GONE
import android.widget.LinearLayout.VISIBLE
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.modules.cultproposal.views.*
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalPresenter
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalView
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel

class CultProposalFragment: Fragment(R.layout.cult_proposal_fragment), CultProposalView {

    lateinit var presenter: CultProposalPresenter

    private val titleTextView: TextView get() = requireView().findViewById(R.id.title)
    private val statusView: CultProposalDetailStatusView get() = requireView().findViewById(R.id.statusView)
    private val guardianView: CultProposalDetailGuardianView get() = requireView().findViewById(R.id.guardianView)
    private val summaryView: CultProposalDetailSummaryView get() = requireView().findViewById(R.id.summaryView)
    private val docsView: CultProposalDetailDocsView get() = requireView().findViewById(R.id.docsView)
    private val tokenomicsView: CultProposalDetailTokenomicsView get() = requireView().findViewById(R.id.tokenomicsView)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        presenter.present()
    }

    override fun update(viewModel: CultProposalViewModel) {
        val proposal = viewModel.proposals.getOrNull(viewModel.selectedIndex) ?: return
        titleTextView.text = proposal.name
        statusView.update(proposal.status)
        proposal.guardianInfo?.let { guardianView.update(it) }
        guardianView.visibility = if (proposal.guardianInfo == null) GONE else VISIBLE
        summaryView.update(proposal.summary)
        docsView.update(proposal.documentsInfo)
        tokenomicsView.update(proposal.tokenomics)
    }
}
