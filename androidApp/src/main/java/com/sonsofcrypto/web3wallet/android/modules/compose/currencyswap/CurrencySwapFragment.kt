package com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.*
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapPresenter
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapPresenterEvent.CurrencyFromChanged
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapView
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapViewModel
import java.text.NumberFormat

class CurrencySwapFragment: Fragment(), CurrencySwapView {

    lateinit var presenter: CurrencySwapPresenter

    private val liveData = MutableLiveData<CurrencySwapViewModel>()
    private val formatter = NumberFormat.getCurrencyInstance()

    init {
        formatter.currency = java.util.Currency.getInstance("USD")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CurrencySwapScreen(it) }
            }
        }
    }

    override fun update(viewModel: CurrencySwapViewModel) {
        liveData.value = viewModel
    }

    override fun presentNetworkFeePicker(networkFees: List<NetworkFee>) {
        println("presentNetworkFeePicker called")
    }

    @Composable
    private fun CurrencySwapScreen(viewModel: CurrencySwapViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { CurrencySwapContent(viewModel) }
        )
    }

    @Composable
    private fun CurrencySwapContent(viewModel: CurrencySwapViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            var value by remember { mutableStateOf(TextFieldValue("")) }
            var showUnderConstruction by remember { mutableStateOf(false) }
            viewModel.data?.let {
                W3WCurrencyEditView(
                    viewModel = it.currencyFrom,
                    value = value,
                    onValueChanged = { newTextFieldValue ->
                        val newValue = applyTextValidation(
                            it.currencyFrom, value.text, newTextFieldValue.text
                        )
                        value = if (value.text.length + 2 == newValue.length) {
                            TextFieldValue(newValue, TextRange(newValue.length))
                        } else if (value.text == newValue && value.text != newTextFieldValue.text) {
                            TextFieldValue(newValue, TextRange(value.selection.start))
                        } else if (value.text.length == newValue.length && value.text != newValue) {
                            TextFieldValue(newValue, TextRange(value.selection.start))
                        } else {
                            TextFieldValue(newValue, newTextFieldValue.selection)
                        }
                        val bigInt = newValue.toBigInt(it.currencyFrom.maxDecimals)
                        presenter.handle(CurrencyFromChanged(bigInt))
                    },
                    onClear = {
                        value = TextFieldValue("")
                        presenter.handle(CurrencyFromChanged(BigInt.zero))
                    },
                    onCurrencyClick = {
                        presenter.handle(CurrencySwapPresenterEvent.CurrencyFromTapped)
                    },
                    onMaxClick = {
                        val bigInt = it.currencyFrom.maxAmount
                        val newValue = bigInt.string(it.currencyFrom.currency)
                        value = TextFieldValue(newValue, TextRange(newValue.length))
                        presenter.handle(CurrencyFromChanged(bigInt))
                    }
                )
                W3WSpacerVertical()
                W3WCurrencyView(viewModel = it.currencyTo,) {
                    presenter.handle(CurrencySwapPresenterEvent.CurrencyToTapped)
                }
            }
            if (showUnderConstruction) {
                W3WUnderConstructionAlert { showUnderConstruction = false }
            }
        }
    }

    private fun BigInt.string(currency: Currency): String = BigDec.from(this)
        .div(BigDec.from(BigInt.from(10).pow(currency.decimals().toLong())))
        .toDecimalString()

    private fun applyTextValidation(
        viewModel: CurrencyAmountPickerViewModel,
        old: String,
        value: String
    ): String {
        val totalOldDots = old.count { it == '.' || it == ',' }
        val totalNewDots = value.count { it == '.' || it == ',' }
        if ((value.decimals?.length?.toUInt() ?: 0u) > viewModel.maxDecimals) { return old }
        if (totalOldDots == 1 && totalNewDots == 2) { return old }
        if (viewModel.maxDecimals > 0u && (value == "." || value == ",")) { return "0." }
        if (old.startsWith("0.") && !value.startsWith("0.")) { return value.drop(1) }
        if (value.startsWith("0") && value.nonDecimals.count() > 1) { return value.drop(1) }
        if (totalNewDots > 1 && ( value.last() == '.' || value.last() == ',')) {
            return value.dropLast(1)
        }
        if (viewModel.maxDecimals == 0u && value == "0") { return "" }
        if (viewModel.maxDecimals == 0u && value == "00") { return "0.0" }
        if (value.any { it == ',' }) { return value.replace(',', '.') }
        return value.trim().replace("-", "")
    }
}

private val CurrencySwapViewModel.data: CurrencySwapViewModel.SwapData? get() {
    val item = items.firstOrNull() ?: return null
    return when (item) {
        is CurrencySwapViewModel.Item.Swap -> { item.swap }
        else -> { null }
    }
}
