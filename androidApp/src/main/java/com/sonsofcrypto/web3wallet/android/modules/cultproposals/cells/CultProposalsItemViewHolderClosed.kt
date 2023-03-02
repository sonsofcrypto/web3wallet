package com.sonsofcrypto.web3wallet.android.modules.cultproposals.cells

import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsViewModel
import smartadapter.viewholder.SmartViewHolder
import java.text.NumberFormat

class CultProposalsItemViewHolderCosed(parentView: ViewGroup):
    SmartViewHolder<CultProposalsViewModel.Item>(parentView, R.layout.cult_proposals_cell_view_closed) {

    private val title: TextView? get() = itemView.byId(R.id.titleView)
    private val approvedView: View? get() = itemView.byId(R.id.approvedView)
    private val approvedVotes: TextView? get() = itemView.byId(R.id.approvedVotes)
    private val rejectedView: View? get() = itemView.byId(R.id.rejectedView)
    private val rejectedVotes: TextView? get() = itemView.byId(R.id.rejectedVotes)
    private val result1Text: TextView? get() = itemView.byId(R.id.result1Text)
    private val result2Text: TextView? get() = itemView.byId(R.id.result2Text)

    private val formatter = NumberFormat.getInstance()

    override fun bind(item: CultProposalsViewModel.Item) {
        title?.text = item.title
        approvedVotes?.text = formatter.format(item.approved.total)
        rejectedVotes?.text = formatter.format(item.rejected.total)
        val totalVotes = item.approved.total + item.rejected.total
        result1Text?.text = item.stateName.uppercase()
        result2Text?.text = Localized(
            "cult.proposals.closed.totalVotes",
            formatter.format(totalVotes)
        )
    }
}