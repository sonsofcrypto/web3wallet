package com.sonsofcrypto.web3wallet.android.modules.compose.currencysend

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3wallet.android.common.extensions.string
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.toBigInt
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkAddressPickerViewModel
import com.sonsofcrypto.web3walletcore.common.viewModels.NetworkFeeViewModel
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendPresenter
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendPresenterEvent.QrCodeScan
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendPresenterEvent.Review
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendView
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendViewModel
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendViewModel.ButtonState
import com.sonsofcrypto.web3walletcore.modules.currencySend.CurrencySendViewModel.Item.*

class CurrencySendFragment: Fragment(), CurrencySendView {

    lateinit var presenter: CurrencySendPresenter
    private var liveData = MutableLiveData<CurrencySendViewModel>()
    private val networkFeesData = MutableLiveData<DialogNetworkFee>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                val dialogNetworkFees by networkFeesData.observeAsState()
                viewModel?.let { CurrencySendScreen(it, dialogNetworkFees) }
            }
        }
    }

    override fun update(viewModel: CurrencySendViewModel) {
        liveData.value = viewModel
    }

    override fun presentNetworkFeePicker(networkFees: List<NetworkFee>, selected: NetworkFee?) {
        networkFeesData.value = DialogNetworkFee(networkFees, selected)
    }

    override fun dismissKeyboard() {}

    @Composable
    private fun CurrencySendScreen(
        viewModel: CurrencySendViewModel,
        dialogNetworkFees: DialogNetworkFee?,
    ) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { CurrencySendContent(viewModel, dialogNetworkFees) }
        )
    }

    @Composable
    private fun CurrencySendContent(
        viewModel: CurrencySendViewModel,
        dialogNetworkFees: DialogNetworkFee?,
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            var value by remember { mutableStateOf(TextFieldValue("")) }
            var showUnderConstruction by remember { mutableStateOf(false) }
            viewModel.addressData()?.let {
                var address by remember { mutableStateOf(TextFieldValue(it.value?: "")) }
                if (address.text != it.value) {
                    val newValue = it.value ?: ""
                    address = TextFieldValue(newValue, TextRange(newValue.length))
                }
                W3WAddressSelectorView(
                    viewModel = it,
                    value = address,
                    onClear = {
                        address = TextFieldValue("")
                        presenter.handle(CurrencySendPresenterEvent.AddressChanged(address.text))
                    },
                    onValueChanged = { newAddress ->
                        address = newAddress
                        presenter.handle(CurrencySendPresenterEvent.AddressChanged(address.text))
                    },
                    onQRCodeClick = { presenter.handle(QrCodeScan) },
                )
                W3WSpacerVertical()
            }
            viewModel.currencyData()?.let {
                W3WCurrencyEditView(
                    viewModel = it,
                    value = value,
                    onValueChanged = { newTextFieldValue ->
                        val newValue = applyTextValidation(
                            it, value.text, newTextFieldValue.text
                        )
                        value = updateTextFieldValueSelection(value, newTextFieldValue, newValue)
                        val bigInt = newValue.toBigInt(it.maxDecimals)
                        presenter.handle(CurrencySendPresenterEvent.AmountChanged(bigInt))
                    },
                    onClear = {
                        value = TextFieldValue("")
                        presenter.handle(CurrencySendPresenterEvent.AmountChanged(BigInt.zero))
                    },
                    onCurrencyClick = {
                        presenter.handle(CurrencySendPresenterEvent.SelectCurrency)
                    },
                    onMaxClick = {
                        val bigInt = it.maxAmount
                        val newValue = bigInt.string(it.maxDecimals)
                        value = TextFieldValue(newValue, TextRange(newValue.length))
                        presenter.handle(CurrencySendPresenterEvent.AmountChanged(bigInt))
                    }
                )
            }
            viewModel.networkData()?.let {
                W3WSpacerVertical()
                W3WNetworkFeeRowView(
                    viewModel = it,
                    onClick = { presenter.handle(CurrencySendPresenterEvent.NetworkFeeTapped) }
                )
            }
            viewModel.buttonData()?.let {
                W3WSpacerVertical()
                SendButton(it)
            }
            if (showUnderConstruction) {
                W3WDialogUnderConstruction { showUnderConstruction = false }
            }
            if (dialogNetworkFees != null) {
                W3WDialogNetworkFeePicker(
                    onDismissRequest = { networkFeesData.value = null },
                    networkFees = dialogNetworkFees.networkFees,
                    networkFeeSelected = dialogNetworkFees.networkFee,
                    onNetworkFeeSelected = {
                        presenter.handle(CurrencySendPresenterEvent.NetworkFeeChanged(it))
                    }
                )
            }
        }
    }

    @Composable
    fun SendButton(viewModel: ButtonState) {
        when (viewModel) {
            ButtonState.INVALID_DESTINATION -> {
                W3WButtonPrimary(
                    title = Localized("currencySend.missing.address"),
                    isEnabled = false,
                )
            }
            ButtonState.ENTER_FUNDS -> {
                W3WButtonPrimary(
                    title = Localized("enterFunds"),
                    isEnabled = false,
                )
            }
            ButtonState.INSUFFICIENT_FUNDS -> {
                W3WButtonPrimary(
                    title = Localized("insufficientFunds"),
                    isEnabled = false,
                )
            }
            ButtonState.READY -> {
                W3WButtonPrimary(
                    title = Localized("send"),
                    onClick = { presenter.handle(Review) }
                )
            }
        }
    }
}

private fun CurrencySendViewModel.addressData(): NetworkAddressPickerViewModel? {
    val item = items.first {
        when (it) {
            is Address -> true
            else -> false
        }
    }
    return (item as? Address)?.data
}

private fun CurrencySendViewModel.currencyData(): CurrencyAmountPickerViewModel? {
    val item = items.first {
        when (it) {
            is Currency -> true
            else -> false
        }
    }
    return (item as? Currency)?.data
}

private fun CurrencySendViewModel.networkData(): NetworkFeeViewModel? {
    val item = items.first {
        when (it) {
            is Send -> true
            else -> false
        }
    }
    return (item as? Send)?.data?.networkFee
}

private fun CurrencySendViewModel.buttonData(): ButtonState? {
    val item = items.first {
        when (it) {
            is Send -> true
            else -> false
        }
    }
    return (item as? Send)?.data?.buttonState
}
