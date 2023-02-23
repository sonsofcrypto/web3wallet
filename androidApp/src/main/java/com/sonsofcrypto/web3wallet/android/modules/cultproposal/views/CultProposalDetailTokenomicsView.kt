package com.sonsofcrypto.web3wallet.android.modules.cultproposal.views

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel

class CultProposalDetailTokenomicsView(
    context: Context, attrs: AttributeSet
): LinearLayout(context, attrs) {

    private val titleLabel: TextView get() = findViewById(R.id.tokenomicsTitle)
    private val rewardAllocationTextView: TextView get() = findViewById(R.id.rewardAllocation)
    private val rewardAllocationValueTextView: TextView get() = findViewById(R.id.rewardAllocationValue)
    private val rewardDistributionTextView: TextView get() = findViewById(R.id.rewardDistribution)
    private val rewardDistributionValueTextView: TextView get() = findViewById(R.id.rewardDistributionValue)
    private val projectETHWalletTextView: TextView get() = findViewById(R.id.projectETHWallet)
    private val projectETHWalletValueTextView: TextView get() = findViewById(R.id.projectETHWalletValue)

    fun update(viewModel: CultProposalViewModel.ProposalDetails.Tokenomics) {
        titleLabel.text = viewModel.title
        rewardAllocationTextView.text = viewModel.rewardAllocation
        rewardAllocationValueTextView.text = viewModel.rewardAllocationValue
        rewardDistributionTextView.text = viewModel.rewardDistribution
        rewardDistributionValueTextView.text = viewModel.rewardDistributionValue
        projectETHWalletTextView.text = viewModel.projectETHWallet
        projectETHWalletValueTextView.text = viewModel.projectETHWalletValue
    }
}