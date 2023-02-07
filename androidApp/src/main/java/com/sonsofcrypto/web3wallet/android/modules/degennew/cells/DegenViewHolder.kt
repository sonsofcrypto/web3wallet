package com.sonsofcrypto.web3wallet.android.modules.degen.cells

import android.view.ViewGroup
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3wallet.android.modules.degennew.DegenNewViewModel
import com.sonsofcrypto.web3walletcore.modules.degen.DegenViewModel
import smartadapter.viewholder.SmartViewHolder

class DegenViewHolder(parentView: ViewGroup) :
    SmartViewHolder<DegenNewViewModel.Item>(parentView, R.layout.view_holder_degen) {

    val title: TextView? get() = itemView.byId(R.id.textView)
    val subtitle: TextView? get() = itemView.byId(R.id.textView)

    override fun bind(viewModel: DegenNewViewModel.Item) {
        title?.text = viewModel.title
        subtitle?.text = viewModel.subtitle
    }
}