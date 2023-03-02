package com.sonsofcrypto.web3wallet.android.modules.cultproposals

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.cells.SectionHeaderViewHolder
import com.sonsofcrypto.web3wallet.android.common.datasourceadapter.DataSourceAdapter
import com.sonsofcrypto.web3wallet.android.common.datasourceadapter.DataSourceAdapterDelegate
import com.sonsofcrypto.web3wallet.android.common.datasourceadapter.IndexPath
import com.sonsofcrypto.web3wallet.android.common.extenstion.byId
import com.sonsofcrypto.web3wallet.android.modules.cultproposals.cells.CultProposalsItemViewHolderCosed
import com.sonsofcrypto.web3wallet.android.modules.cultproposals.cells.CultProposalsItemViewHolderPending
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsPresenter
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsView
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsViewModel
import com.sonsofcrypto.web3walletcore.modules.degenCultProposals.CultProposalsViewModel.Section
import smartadapter.extension.setBackgroundAttribute

class CultProposalsFragment:
    Fragment(R.layout.cult_proposals_fragment), CultProposalsView, DataSourceAdapterDelegate {

    lateinit var presenter: CultProposalsPresenter
    private lateinit var viewModel: CultProposalsViewModel
    private val segmentGroup: FrameLayout get() = requireView().byId(R.id.segmentGroup)
    private val segment1: TextView get() = requireView().byId(R.id.segment1)
    private val segment2: TextView get() = requireView().byId(R.id.segment2)
    private val recyclerView: RecyclerView get() = requireView().byId(R.id.recycler_view)
    private lateinit var adapter: DataSourceAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureUI()
        presenter.present()
    }

    override fun numberOfSections(): Int = viewModel.sections.size

    override fun numberCellsIn(section: Int): Int = viewModel.sections[section].items.count()

    override fun didSelectCellAt(idxPath: IndexPath) {
        presenter.handle(CultProposalsPresenterEvent.SelectProposal(idxPath.item))
    }

    override fun update(viewModel: CultProposalsViewModel) {
        this.viewModel = viewModel
        refreshSegmentControl()
        val classType = if (viewModel.sections.firstOrNull()?.isPending == true) {
            CultProposalsItemViewHolderPending::class
        } else {
            CultProposalsItemViewHolderCosed::class
        }
        val map = hashMapOf(
            String::class to SectionHeaderViewHolder::class,
            CultProposalsViewModel.Item::class to classType,
        )
        adapter = DataSourceAdapter(this, recyclerView, map)
        if (viewModel.sections.isEmpty()) { return }
        val items = viewModel.sections
            .map { listOf(it.title) + it.items }
            .reduce { sum, elem -> sum + elem }
        adapter?.reloadData(items.toMutableList())
    }

    private fun configureUI() {
        segment1.setOnClickListener { presenter.handle(CultProposalsPresenterEvent.SelectPendingProposals) }
        segment2.setOnClickListener { presenter.handle(CultProposalsPresenterEvent.SelectClosedProposals) }
    }

    private fun refreshSegmentControl() {
        if (viewModel.sections.isEmpty()) {
            segmentGroup.isVisible = false
            return
        }
        segmentGroup.isVisible = true
        refreshSegment(
            Localized("cult.proposals.segmentedControl.pending"),
            segment1,
            viewModel.sections.first() is Section.Pending
        )
        refreshSegment(
            Localized("cult.proposals.segmentedControl.closed"),
            segment2,
            viewModel.sections.first() is Section.Closed
        )
    }

    private fun refreshSegment(title: String?, segment: TextView, isSelected: Boolean) {
        segment.text = title
        if (isSelected) {
            segment.setBackgroundAttribute(R.attr.segmentedControlBackgroundSelected)
        } else {
            segment.setBackgroundColor(Color.TRANSPARENT)
        }
    }

}

private val CultProposalsViewModel.sections: List<Section> get() = when (this) {
    is CultProposalsViewModel.Loading -> { emptyList() }
    is CultProposalsViewModel.Loaded -> { this.sections }
    is CultProposalsViewModel.Error -> { emptyList()
    }
}

private val Section.isPending: Boolean get() = when (this) {
    is Section.Pending -> { true }
    is Section.Closed -> { false }
}

private val Section.title: String get() = when (this) {
    is Section.Pending -> { this.title }
    is Section.Closed -> { this.title }
}

private val Section.items: List<CultProposalsViewModel.Item> get() = when (this) {
    is Section.Pending -> { this.items }
    is Section.Closed -> { this.items }
}

private val Section.footer: CultProposalsViewModel.Footer get() = when (this) {
    is Section.Pending -> { this.footer }
    is Section.Closed -> { this.footer }
}