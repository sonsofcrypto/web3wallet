package com.sonsofcrypto.web3wallet.android.modules.improvementproposal

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.Fragment
import coil.load
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenter
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalView
import com.sonsofcrypto.web3walletcore.modules.improvementProposal.ImprovementProposalViewModel

class ImprovementProposalFragment:
    Fragment(R.layout.improvement_proposal_fragment), ImprovementProposalView {

    lateinit var presenter: ImprovementProposalPresenter

    private val statusView: TextView get() = requireView().findViewById(R.id.textView)
    private val imageView: ImageView get() = requireView().findViewById(R.id.imageView)
    private val detailTitle: TextView get() = requireView().findViewById(R.id.detailTitle)
    private val detailBody: TextView get() = requireView().findViewById(R.id.detailBody)
    private val voteButton: Button get() = requireView().findViewById(R.id.button)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureUI(view)
        presenter.present()
    }

    override fun update(viewModel: ImprovementProposalViewModel) {
        statusView.text = viewModel.status
        imageView.load(viewModel.imageUrl)
        detailTitle.text = Localized("proposal.summary.header")
        detailBody.text = viewModel.body
        voteButton.text = Localized("proposal.button.vote")
    }

    private fun configureUI(view: View) {
        view.post {
            imageView.layoutParams.height = view.width * 9 / 16
            imageView.requestLayout()
        }
        voteButton.setOnClickListener {
            presenter.handle(ImprovementProposalPresenterEvent.Vote)
        }
    }
}