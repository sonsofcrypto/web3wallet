package com.sonsofcrypto.web3wallet.android.common.cells

import android.view.ViewGroup
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import smartadapter.viewholder.SmartViewHolder

class SectionHeaderViewHolder(parentView: ViewGroup) :
    SmartViewHolder<String>(parentView, R.layout.view_holder_section_header) {

    init {
        itemView.setPadding(16, 16, 16, 16)
    }

    val title: TextView? get() = itemView.byId(R.id.textView)

    override fun bind(viewModel: String) {
        title?.text = viewModel
    }
}
