package com.sonsofcrypto.web3wallet.android.modules.cultproposals.cells

import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.widget.Button
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsViewModel
import smartadapter.viewholder.SmartViewHolder
import java.text.NumberFormat

class CultProposalsItemViewHolderPending(parentView: ViewGroup):
    SmartViewHolder<CultProposalsViewModel.Item>(parentView, R.layout.cult_proposals_cell_view_pending) {

    private val title: TextView? get() = itemView.byId(R.id.titleView)
    private val approvedView: View? get() = itemView.byId(R.id.approvedView)
    private val approvedVotes: TextView? get() = itemView.byId(R.id.approvedVotes)
    private val rejectedView: View? get() = itemView.byId(R.id.rejectedView)
    private val rejectedVotes: TextView? get() = itemView.byId(R.id.rejectedVotes)
    private val approveButton: Button? get() = itemView.byId(R.id.approveButton)
    private val rejectButton: Button? get() = itemView.byId(R.id.rejectButton)

    private val formatter = NumberFormat.getInstance()

    override fun bind(item: CultProposalsViewModel.Item) {
        title?.text = item.title
        approvedView?.setBackgroundColor(R.attr.navigationIconTint)
        approvedView?.clipToOutline = true
        approvedVotes?.text = formatter.format(item.approved.total)
        approveButton?.setOnClickListener { println("approve") }
        rejectedVotes?.text = formatter.format(item.rejected.total)
        rejectButton?.setOnClickListener { println("reject") }
    }
}