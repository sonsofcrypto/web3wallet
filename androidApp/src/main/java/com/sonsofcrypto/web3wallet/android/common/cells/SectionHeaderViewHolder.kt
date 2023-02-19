package com.sonsofcrypto.web3wallet.android.common.cells

import android.view.ViewGroup
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import smartadapter.viewholder.SmartViewHolder

class SectionHeaderViewHolder(parentView: ViewGroup) :
    SmartViewHolder<String>(parentView, R.layout.degen_section_view) {

    val title: TextView? get() = itemView.byId(R.id.textView)

    override fun bind(viewModel: String) {
        title?.text = viewModel
    }
}
