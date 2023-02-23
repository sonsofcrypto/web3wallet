package com.sonsofcrypto.web3wallet.android.modules.cultproposal.views

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel

class CultProposalDetailGuardianView(
    context: Context, attrs: AttributeSet
): LinearLayout(context, attrs) {

    private val titleTextView: TextView get() = findViewById(R.id.guardianTitle)
    private val nameTextView: TextView get() = findViewById(R.id.guardianName)
    private val nameValueTextView: TextView get() = findViewById(R.id.guardianNameValue)
    private val socialTextView: TextView get() = findViewById(R.id.guardianSocial)
    private val socialValueTextView: TextView get() = findViewById(R.id.guardianSocialValue)
    private val walletTextView: TextView get() = findViewById(R.id.guardianWallet)
    private val walletValueTextView: TextView get() = findViewById(R.id.guardianWalletValue)

    fun update(viewModel: CultProposalViewModel.ProposalDetails.GuardianInfo) {
        titleTextView.text = viewModel.title
        nameTextView.text = viewModel.name
        nameValueTextView.text = viewModel.nameValue
        socialTextView.text = viewModel.socialHandle
        socialValueTextView.text = viewModel.socialHandleValue
        walletTextView.text = viewModel.wallet
        walletValueTextView.text = viewModel.walletValue
    }
}