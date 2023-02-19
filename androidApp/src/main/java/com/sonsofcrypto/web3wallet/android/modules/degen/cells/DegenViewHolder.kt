package com.sonsofcrypto.web3wallet.android.modules.degen.cells

import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3walletcore.modules.degen.DegenViewModel
import smartadapter.viewholder.SmartViewHolder

class DegenViewHolder(parentView: ViewGroup) :
    SmartViewHolder<DegenViewModel.Item>(parentView, R.layout.degen_cell_view) {

    val image: ImageView? get() = itemView.byId(R.id.imageView)
    val title: TextView? get() = itemView.byId(R.id.textView)
    val subtitle: TextView? get() = itemView.byId(R.id.textView2)

    override fun bind(viewModel: DegenViewModel.Item) {
        title?.text = viewModel.title
        subtitle?.text = viewModel.subtitle

        if (viewModel.isEnabled) {
            title?.setTextAppearance(R.style.TextPrimary)
        } else {
            title?.setTextAppearance(R.style.TextSecondary)
        }
    }
}