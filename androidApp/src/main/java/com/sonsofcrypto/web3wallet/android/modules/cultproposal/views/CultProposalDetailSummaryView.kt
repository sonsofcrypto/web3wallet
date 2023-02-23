package com.sonsofcrypto.web3wallet.android.modules.cultproposal.views

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel

class CultProposalDetailSummaryView(
    context: Context, attrs: AttributeSet
): LinearLayout(context, attrs) {

    private val titleTextView: TextView get() = findViewById(R.id.summaryTitle)
    private val bodyTextView: TextView get() = findViewById(R.id.summaryBody)

    fun update(viewModel: CultProposalViewModel.ProposalDetails.Summary) {
        titleTextView.text = viewModel.title
        bodyTextView.text = viewModel.summary
    }
}