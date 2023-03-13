package com.sonsofcrypto.web3wallet.android.modules.compose.currencypicker

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.extensions.*
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerPresenter
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerPresenterEvent.SelectCurrency
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerPresenterEvent.SelectFavouriteCurrency
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerView
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel.Currency
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel.Position.LAST
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel.Position.SINGLE
import com.sonsofcrypto.web3walletcore.modules.currencyPicker.CurrencyPickerViewModel.Section

class CurrencyPickerFragment: Fragment(), CurrencyPickerView {

    lateinit var presenter: CurrencyPickerPresenter
    private val liveData = MutableLiveData<CurrencyPickerViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CurrencyPickerScreen(it) }
            }
        }
    }

    override fun update(viewModel: CurrencyPickerViewModel) {
        liveData.value = viewModel
    }

    @Composable
    private fun CurrencyPickerScreen(viewModel: CurrencyPickerViewModel) {
        W3WScreen(
            navBar = {
                W3WNavigationBar(
                    title = viewModel.title,
                    leadingIcon = if (viewModel.showAddCustomCurrency) ({ AddCurrency() })
                                  else null,
                    content = { SearchBar() }
                )
            },
            content = { CurrencyPickerContent(viewModel) }
        )
    }
    @Composable
    private fun AddCurrency() {
        W3WIcon(
            id = R.drawable.icon_add_24,
            colorFilter = ColorFilter.tint(theme().colors.navBarTint),
            onClick = { presenter.handle(CurrencyPickerPresenterEvent.AddCustomCurrency) }
        )
    }

    @Composable
    private fun SearchBar() {
        var value by remember { mutableStateOf("") }
        Column(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            W3WSearchBox(
                value = value,
                onValueChange = {
                    value = it
                    presenter.handle(CurrencyPickerPresenterEvent.Search(value))
                },
                modifier = Modifier.fillMaxWidth(),
                leadingIcon = { W3WIcon(id = R.drawable.icon_search_24) },
                trailingIcon = {
                    W3WClearIcon {
                        value = ""
                        presenter.handle(CurrencyPickerPresenterEvent.Search(value))
                    }
                },
            )
            W3WSpacerVertical(theme().shapes.padding.threeQuarter)
        }
    }

    @Composable
    private fun CurrencyPickerContent(viewModel: CurrencyPickerViewModel) {
        LazyColumn(
            modifier = Modifier.fillMaxSize()
        ) {
            var totalItems = 0
            viewModel.sections.favourites?.currencies?.size?.let { totalItems += 1 + it }
            viewModel.sections.other?.currencies?.size?.let { totalItems += 1 + it }
            items(totalItems) {idx ->
                val info = getItemForIndex(idx, viewModel.sections)
                (info.value as? String)?.let { Row(it) }
                (info.value as? Currency)?.let {
                    Row(
                        isMultiSelect = viewModel.allowMultipleSelection,
                        currency = it,
                        onClick = {
                            if (info.isFavouriteCurrency) {
                                presenter.handle(SelectFavouriteCurrency(info.idx))
                            } else {
                                presenter.handle(SelectCurrency(info.idx))
                            }
                        }
                    )
                }
            }
        }
    }

    @Composable
    private fun Row(title: String) {
        Column(modifier = Modifier.fillMaxWidth()) {
            W3WText(
                text = title,
                style = theme().fonts.bodyBold,
                modifier = Modifier.padding(
                    start = theme().shapes.padding,
                    end = theme().shapes.padding,
                    top = theme().shapes.padding.half,
                    bottom = theme().shapes.padding.half
                )
            )
            W3WDivider(modifier = Modifier.fillMaxWidth())
        }
    }

    @Composable
    private fun Row(isMultiSelect: Boolean, currency: Currency, onClick: () -> Unit) {
        val topBottomPadding = if(currency.tokens != null) theme().shapes.padding.quarter
                               else theme().shapes.padding.threeQuarter
        Column(modifier = ModifierClickable(onClick = onClick).fillMaxWidth()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(
                        start = theme().shapes.padding,
                        end = theme().shapes.padding,
                        top = topBottomPadding,
                        bottom = topBottomPadding,
                    ),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (isMultiSelect) {
                    W3WIcon(
                        id = if(currency.isSelected == true) R.drawable.icon_check_circle_24
                             else R.drawable.icon_check_circle_empty_24
                    )
                    W3WSpacerHorizontal()
                }
                W3WIcon(
                    id = drawableId(
                        name = currency.imageName,
                        defaultId = R.drawable.icon_default_currency_24,
                    ),
                    modifier = Modifier.clip(RoundedCornerShape(24.dp / 2))
                )
                W3WSpacerHorizontal()
                W3WText(
                    text = currency.name,
                    modifier = Modifier.weight(1f),
                )
                W3WSpacerHorizontal()
                Column(
                    modifier = Modifier.weight(1f)
                ) {
                    currency.tokens?.let {
                        W3WText(
                            text = it.annotatedStringBody(),
                            textAlign = TextAlign.End,
                            modifier = Modifier.fillMaxWidth(),
                        )
                    }
                    currency.fiat?.let {
                        W3WText(
                            text = it.annotatedStringBody(),
                            textAlign = TextAlign.End,
                            modifier = Modifier.fillMaxWidth(),
                        )
                    }
                }
            }
            W3WDivider(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(
                        start = if (currency.position == SINGLE || currency.position == LAST) 0.dp
                        else theme().shapes.padding
                    )
            )
        }
    }

    data class IndexInfo(
        val value: Any?,
        val isFavouriteCurrency: Boolean,
        val idx: Int
    )

    private fun getItemForIndex(idx: Int, sections: List<Section>): IndexInfo {
        val favouriteCurrencies = sections.favourites?.currencies ?: emptyList()
        val otherCurrencies = sections.other?.currencies ?: emptyList()
        if (idx == 0 && favouriteCurrencies.isNotEmpty()) {
            return IndexInfo(
                value = sections.favourites?.name,
                isFavouriteCurrency = false,
                idx = 0
            )
        }
        if (idx == 0 && otherCurrencies.isNotEmpty()) {
            return IndexInfo(
                value = sections.other?.name,
                isFavouriteCurrency = false,
                idx = idx
            )
        }
        val favouriteTotal = if (favouriteCurrencies.isEmpty()) 0 else (favouriteCurrencies.size + 1)
        if (idx < favouriteTotal) {
            return IndexInfo(
                value = sections.favourites?.currencies?.getOrNull(idx - 1),
                isFavouriteCurrency = true,
                idx = idx - 1
            )
        }
        if (idx == favouriteTotal && otherCurrencies.isNotEmpty()) {
            return IndexInfo(
                value = sections.other?.name,
                isFavouriteCurrency = false,
                idx = idx
            )
        }
        if (idx <= (if (otherCurrencies.isEmpty()) 0 else (favouriteTotal + otherCurrencies.size + 1))) {
            return IndexInfo(
                value = sections.other?.currencies?.getOrNull(idx - favouriteTotal - 1),
                isFavouriteCurrency = false,
                idx = idx - favouriteTotal - 1
            )
        }
        return IndexInfo(null, false, 0)
    }
}

private val List<Section>.networks: Section? get() = firstOrNull {
    when (it) {
        is Section.Networks -> true
        else -> false
    }
}

private val List<Section>.favourites: Section? get() = firstOrNull {
    when (it) {
        is Section.FavouriteCurrencies -> true
        else -> false
    }
}

private val List<Section>.other: Section? get() = firstOrNull {
    when (it) {
        is Section.Currencies -> true
        else -> false
    }
}

private val Section.networks: List<CurrencyPickerViewModel.Network> get() {
    return when (this) {
        is Section.Networks -> this.networks
        else -> emptyList()
    }
}

private val Section.currencies: List<Currency> get() {
    return when (this) {
        is Section.FavouriteCurrencies -> this.items
        is Section.Currencies -> this.items
        else -> emptyList()
    }
}
