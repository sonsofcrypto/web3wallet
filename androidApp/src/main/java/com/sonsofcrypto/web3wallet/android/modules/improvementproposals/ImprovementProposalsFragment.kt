package com.sonsofcrypto.web3wallet.android.modules.improvementproposals

import android.os.Bundle
import android.view.View
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
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsView
import com.sonsofcrypto.web3walletcore.modules.improvementProposals.ImprovementProposalsViewModel

class ImprovementProposalsFragment:
    Fragment(R.layout.improvement_proposals_fragment), ImprovementProposalsView, DataSourceAdapterDelegate {

    lateinit var presenter: ImprovementProposalsPresenter
    private lateinit var viewModel: ImprovementProposalsViewModel
    private val recyclerView: RecyclerView get() = requireView().byId(R.id.recycler_view)
    private lateinit var adapter: DataSourceAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val map = hashMapOf(
            ImprovementProposalsViewModel.Item::class to ImprovementProposalsItemViewHolder::class,
            String::class to SectionHeaderViewHolder::class,
        )
        adapter = DataSourceAdapter(this, recyclerView, map)
        presenter.present()
    }

    override fun update(viewModel: ImprovementProposalsViewModel) {
        this.viewModel = viewModel
        if (viewModel.categories().isEmpty()) return
        val items = this.viewModel.categories()
            .map { listOf(it.title) + it.items }
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
        TODO("Not yet implemented")
    }
}

private fun ImprovementProposalsViewModel.categories():
        List<ImprovementProposalsViewModel.Category> = when (this) {
    is ImprovementProposalsViewModel.Loading -> { emptyList() }
    is ImprovementProposalsViewModel.Loaded -> { this.categories }
    is ImprovementProposalsViewModel.Error -> { emptyList() }
}