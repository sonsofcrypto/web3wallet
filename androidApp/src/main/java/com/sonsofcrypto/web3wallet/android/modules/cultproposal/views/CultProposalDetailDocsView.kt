package com.sonsofcrypto.web3wallet.android.modules.cultproposal.views

import android.content.Context
import android.util.AttributeSet
import android.widget.LinearLayout
import android.widget.TextView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3walletcore.app.App
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel.ProposalDetails.DocumentsInfo.Document
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel.ProposalDetails.DocumentsInfo.Document.Item.Link
import com.sonsofcrypto.web3walletcore.modules.degenCultProposal.CultProposalViewModel.ProposalDetails.DocumentsInfo.Document.Item.Note

class CultProposalDetailDocsView(
    context: Context, attrs: AttributeSet
): LinearLayout(context, attrs) {

    private val titleTextView: TextView get() = findViewById(R.id.docsTitle)
    private val layout: LinearLayout get() = findViewById(R.id.docsLayout)

    fun update(viewModel: CultProposalViewModel.ProposalDetails.DocumentsInfo) {
        titleTextView.text = viewModel.title
        viewModel.documents.forEach { addProductsRow(it) }
    }

    private fun addProductsRow(document: Document) {
        val titleView = TextView(context)
        titleView.text = document.title
        titleView.setTextAppearance(R.style.FontSubheadlineSecondary)
        titleView.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
        layout.addView(titleView)

        document.items.forEach { item ->
            val textView = TextView(context)
            textView.setTextAppearance(R.style.FontSubheadline)
            when (item) {
                is Link -> {
                    textView.text = item.displayName
                    textView.setOnClickListener { App.openUrl(item.url) }
                }
                is Note -> { textView.text = item.text }
            }
            textView.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            if (textView.text.trim().isNotEmpty()) layout.addView(textView)
        }
    }
}