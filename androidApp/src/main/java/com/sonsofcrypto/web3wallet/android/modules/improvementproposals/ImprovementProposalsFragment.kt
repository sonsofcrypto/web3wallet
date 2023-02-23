package com.sonsofcrypto.web3wallet.android.modules.improvementproposals

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
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
import com.sonsofcrypto.web3wallet.android.modules.improvementproposals.cells.ImprovementProposalsItemViewHolder
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsPresenter
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsPresenterEvent.Category
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsView
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsViewModel
import smartadapter.extension.setBackgroundAttribute

class ImprovementProposalsFragment:
    Fragment(R.layout.improvement_proposals_fragment), ImprovementProposalsView, DataSourceAdapterDelegate {

    lateinit var presenter: ImprovementProposalsPresenter
    private lateinit var viewModel: ImprovementProposalsViewModel
    private val segmentGroup: FrameLayout get() = requireView().byId(R.id.segmentGroup)
    private val segment1: TextView get() = requireView().byId(R.id.segment1)
    private val segment2: TextView get() = requireView().byId(R.id.segment2)
    private val segment3: TextView get() = requireView().byId(R.id.segment3)
    private val recyclerView: RecyclerView get() = requireView().byId(R.id.recycler_view)
    private lateinit var adapter: DataSourceAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureUI()
        presenter.present()
    }

    override fun update(viewModel: ImprovementProposalsViewModel) {
        this.viewModel = viewModel
        refreshSegmentControl()
        if (viewModel.categories().isEmpty()) return
        val items = this.viewModel.categories()
            .filter {
                it.title == viewModel.selectedCategory()?.title
            }
            .map { listOf(it.description) + it.items }
            .reduce { sum, elem -> sum + elem }
        adapter?.reloadData(items.toMutableList())
    }

    override fun numberOfSections(): Int {
        return viewModel.categories().count()
    }

    override fun numberCellsIn(section: Int): Int {
        return viewModel.categories()[section].items.count()
    }

    override fun didSelectCellAt(idxPath: IndexPath) {
        presenter.handle(ImprovementProposalsPresenterEvent.Proposal(idxPath.item))
    }

    private fun configureUI() {
        segment1.setOnClickListener { presenter.handle(Category(0)) }
        segment2.setOnClickListener { presenter.handle(Category(1)) }
        segment3.setOnClickListener { presenter.handle(Category(2)) }
        val map = hashMapOf(
            ImprovementProposalsViewModel.Item::class to ImprovementProposalsItemViewHolder::class,
            String::class to SectionHeaderViewHolder::class,
        )
        adapter = DataSourceAdapter(this, recyclerView, map)
    }

    private fun refreshSegmentControl() {
        if (viewModel.categories().isEmpty()) {
            segmentGroup.isVisible = false
            return
        }
        segmentGroup.isVisible = true
        refreshSegment(
            viewModel.categories().getOrNull(0)?.title,
            segment1,
            viewModel.selectedCategory() == viewModel.categories().getOrNull(0)
        )
        refreshSegment(
            viewModel.categories().getOrNull(1)?.title,
            segment2,
            viewModel.selectedCategory() == viewModel.categories().getOrNull(1)
        )
        refreshSegment(
            viewModel.categories().getOrNull(2)?.title,
            segment3,
            viewModel.selectedCategory() == viewModel.categories().getOrNull(2)
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

private fun ImprovementProposalsViewModel.categories():
        List<ImprovementProposalsViewModel.Category> = when (this) {
    is ImprovementProposalsViewModel.Loading -> { emptyList() }
    is ImprovementProposalsViewModel.Loaded -> { this.categories }
    is ImprovementProposalsViewModel.Error -> { emptyList() }
}