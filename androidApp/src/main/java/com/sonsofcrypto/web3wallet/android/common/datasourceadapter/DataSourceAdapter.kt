package com.sonsofcrypto.web3wallet.android.common.datasourceadapter

import androidx.recyclerview.widget.RecyclerView
import smartadapter.SmartRecyclerAdapter
import smartadapter.SmartViewHolderType
import smartadapter.viewevent.listener.OnClickEventListener
import smartadapter.viewevent.model.ViewEvent
import java.util.HashMap
import kotlin.reflect.KClass

data class IndexPath(
    val section: Int,
    val item: Int
)

interface DataSourceAdapterDelegate {
    fun numberOfSections(): Int
    fun numberCellsIn(section: Int): Int
    fun didSelectCellAt(idxPath: IndexPath)
}

class DataSourceAdapter(
    var delegate: DataSourceAdapterDelegate?, // TODO: Weak
    val recyclerView: RecyclerView,
    val viewHolderMapper: HashMap<KClass<*>, SmartViewHolderType>
) {

    private var sectionCount: Int = 0
    private var itemsCounts: List<Int> = emptyList()
    private var adapter: SmartRecyclerAdapter

    init {
        var builder = SmartRecyclerAdapter.empty()
        viewHolderMapper.forEach { builder = builder.map(it.key, it.value) }
        adapter = builder.add(
            OnClickEventListener { e: ViewEvent.OnClick -> handleClick(e) }
        ).into(recyclerView)
    }

    fun reloadData(items: MutableList<Any>) {
        sectionCount = delegate?.numberOfSections() ?: 0
        itemsCounts = (0 until sectionCount).map {
            delegate?.numberCellsIn(it) ?: 0
        }
        adapter.setItems(items)
    }

    private fun handleClick(event: ViewEvent.OnClick) {
        var sectionOffset = 1
        for (section in 0 until sectionCount) {
            for (idx in 0 until itemsCounts[section]) {
                if (event.position == idx + sectionOffset) {
                    delegate?.didSelectCellAt(IndexPath(section, idx))
                    return
                }
            }
            sectionOffset += itemsCounts[section] + 1
        }
    }
}

