package com.sonsofcrypto.web3wallet.android.modules.degen

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
import com.sonsofcrypto.web3wallet.android.modules.degen.cells.DegenViewHolder
import com.sonsofcrypto.web3walletcore.modules.degen.DegenPresenter
import com.sonsofcrypto.web3walletcore.modules.degen.DegenPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.degen.DegenView
import com.sonsofcrypto.web3walletcore.modules.degen.DegenViewModel

class DegenFragment:
    Fragment(R.layout.degen_fragment), DegenView, DataSourceAdapterDelegate {

    val recyclerView: RecyclerView get() = requireView().byId(R.id.recycler_view)
    lateinit var presenter: DegenPresenter
    private lateinit var adapter: DataSourceAdapter
    private lateinit var viewModel: DegenViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val map = hashMapOf(
            DegenViewModel.Item::class to DegenViewHolder::class,
            String::class to SectionHeaderViewHolder::class,
        )
        adapter = DataSourceAdapter(this, recyclerView, map)
        presenter.present()
    }

    override fun update(viewModel: DegenViewModel) {
        this.viewModel = viewModel
        val items = this.viewModel.sections
            .map {
                when (it) {
                    is DegenViewModel.Section.Header -> { listOf(it.title) }
                    is DegenViewModel.Section.Group -> { it.items }
                }
            }
            .reduce { sum, elem -> sum + elem }
        adapter?.reloadData(items.toMutableList())
    }

    override fun popToRootAndRefresh() {

    }

    override fun numberOfSections(): Int = 2

    override fun numberCellsIn(section: Int): Int
        = viewModel?.sections?.get(section + 1)?.items()?.count() ?: 0

    override fun didSelectCellAt(idxPath: IndexPath) {
        if (idxPath.section != 0) presenter.handle(DegenPresenterEvent.ComingSoon)
        else presenter.handle(DegenPresenterEvent.DidSelectCategory(idxPath.item))
    }
}

private fun DegenViewModel.Section.items(): List<Any>? = when (this) {
    is DegenViewModel.Section.Header -> { null }
    is DegenViewModel.Section.Group -> { this.items }
}
