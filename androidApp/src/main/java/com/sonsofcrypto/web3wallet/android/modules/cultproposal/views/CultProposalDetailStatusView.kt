package com.sonsofcrypto.web3wallet.android.modules.cultproposal.views

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel

class CultProposalDetailStatusView(
    context: Context, attrs: AttributeSet
): LinearLayout(context, attrs) {

    private val statusView: LinearLayout get() = findViewById(R.id.statusView)
    private val statusTextView: TextView get() = findViewById(R.id.statusTextView)

    fun update(viewModel: CultProposalViewModel.ProposalDetails.Status) {
        when (viewModel) {
            CultProposalViewModel.ProposalDetails.Status.PENDING -> {
                statusTextView.text = Localized("pending")
                statusView.setBackgroundResource(R.drawable.status_view_round_active)
            }
            CultProposalViewModel.ProposalDetails.Status.CLOSED -> {
                statusTextView.text = Localized("closed")
                statusView.setBackgroundResource(R.drawable.status_view_round_inactive)
            }
        }
    }
}