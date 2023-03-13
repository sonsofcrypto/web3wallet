package com.sonsofcrypto.web3wallet.android.modules.compose.currencyadd

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.OutlinedTextField
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.input.KeyboardType
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddPresenter
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddPresenterEvent
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddPresenterEvent.InputChanged
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddView
import com.sonsofcrypto.web3walletcore.modules.currencyAdd.CurrencyAddViewModel

class CurrencyAddFragment: Fragment(), CurrencyAddView {

    lateinit var presenter: CurrencyAddPresenter
    private val liveData = MutableLiveData<CurrencyAddViewModel>()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        presenter.present()
        return ComposeView(requireContext()).apply {
            setContent {
                val viewModel by liveData.observeAsState()
                viewModel?.let { CurrencyAddScreen(it) }
            }
        }
    }

    override fun update(viewModel: CurrencyAddViewModel) {
        liveData.value = viewModel
    }

    override fun dismissKeyboard() {}

    @Composable
    private fun CurrencyAddScreen(viewModel: CurrencyAddViewModel) {
        W3WScreen(
            navBar = { W3WNavigationBar(title = viewModel.title) },
            content = { CurrencyAddContent(viewModel) }
        )
    }

    @Composable
    private fun CurrencyAddContent(viewModel: CurrencyAddViewModel) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(theme().shapes.padding)
        ) {
            CurrencyAddDetails(viewModel)
            W3WSpacerVertical()
            W3WButtonPrimary(
                title = viewModel.saveButtonTitle,
                onClick = {
                    presenter.handle(CurrencyAddPresenterEvent.AddCurrency)
                }
            )
        }
    }

    @Composable
    private fun CurrencyAddDetails(viewModel: CurrencyAddViewModel) {
        var address by remember { mutableStateOf("") }
        if (address != viewModel.contractAddress.value) {
            address = viewModel.contractAddress.value ?: ""
        }
        var name by remember { mutableStateOf("") }
        var symbol by remember { mutableStateOf("") }
        var decimals by remember { mutableStateOf("") }
        Column(
            modifier = Modifier.fillMaxWidth()
        ) {
            W3WTextFieldOutlined(
                value = address,
                label = { Text(viewModel.contractAddress.name) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(viewModel.contractAddress.placeholder) },
                onValueChange = {
                    address = it
                    presenter.handle(InputChanged(viewModel.contractAddress.type, address))
                },
                isError = viewModel.contractAddress.hint?.isNotEmpty() ?: false,
                trailingIcon = {
                    W3WClearIcon {
                        address = ""
                        presenter.handle(InputChanged(viewModel.contractAddress.type, address))
                    }
                },
            )
            if (viewModel.contractAddress.hint != null) {
                W3WText(
                    text = viewModel.contractAddress.hint ?: "",
                    style = theme().fonts.footnote,
                    color = theme().colors.textFieldError,
                )
            }
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WTextFieldOutlined(
                value = name,
                label = { Text(viewModel.name.name) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(viewModel.name.placeholder) },
                onValueChange = {
                    name = it
                    presenter.handle(InputChanged(viewModel.name.type, name))
                },
                isError = viewModel.name.hint?.isNotEmpty() ?: false,
                trailingIcon = {
                    W3WClearIcon {
                        name = ""
                        presenter.handle(InputChanged(viewModel.name.type, name))
                    }
                },
            )
            if (viewModel.name.hint != null) {
                W3WText(
                    text = viewModel.name.hint ?: "",
                    style = theme().fonts.footnote,
                    color = theme().colors.textFieldError,
                )
            }
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WTextFieldOutlined(
                value = symbol,
                label = { Text(viewModel.symbol.name) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(viewModel.symbol.placeholder) },
                onValueChange = {
                    symbol = it
                    presenter.handle(InputChanged(viewModel.symbol.type, symbol))
                },
                isError = viewModel.symbol.hint?.isNotEmpty() ?: false,
                trailingIcon = {
                    W3WClearIcon {
                        symbol = ""
                        presenter.handle(InputChanged(viewModel.symbol.type, symbol))
                    }
                },
            )
            if (viewModel.symbol.hint != null) {
                W3WText(
                    text = viewModel.symbol.hint ?: "",
                    style = theme().fonts.footnote,
                    color = theme().colors.textFieldError,
                )
            }
            W3WSpacerVertical(theme().shapes.padding.half)
            W3WTextFieldOutlined(
                value = decimals,
                label = { Text(viewModel.decimals.name) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(viewModel.decimals.placeholder) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                onValueChange = {
                    decimals = it
                    presenter.handle(InputChanged(viewModel.decimals.type, decimals))
                },
                isError = viewModel.decimals.hint?.isNotEmpty() ?: false,
                trailingIcon = {
                    W3WClearIcon {
                        decimals = ""
                        presenter.handle(InputChanged(viewModel.decimals.type, decimals))
                    }
                },
            )
            if (viewModel.decimals.hint != null) {
                W3WText(
                    text = viewModel.decimals.hint ?: "",
                    style = theme().fonts.footnote,
                    color = theme().colors.textFieldError,
                )
            }
        }
    }
}