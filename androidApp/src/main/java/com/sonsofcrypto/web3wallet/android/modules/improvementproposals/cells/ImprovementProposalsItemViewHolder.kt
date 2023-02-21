package com.sonsofcrypto.web3wallet.android.modules.improvementproposals.cells

import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsViewModel
import smartadapter.viewholder.SmartViewHolder

class ImprovementProposalsItemViewHolder(parentView: ViewGroup):
    SmartViewHolder<ImprovementProposalsViewModel.Item>(parentView, R.layout.improvement_proposals_cell_view) {

    val title: TextView? get() = itemView.byId(R.id.textView)
    val subtitle: TextView? get() = itemView.byId(R.id.textView2)
    val vote: Button get() = itemView.byId(R.id.button)

    override fun bind(item: ImprovementProposalsViewModel.Item) {
        title?.text = item.title
        subtitle?.text = item.subtitle
        vote.text = Localized("proposals.button.title")
        vote.setOnClickListener {
            println("Tapped vote for: ${item.id}")
        }
    }
}