package com.sonsofcrypto.web3wallet.android.modules.compose.currencyswap

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import androidx.lifecycle.MutableLiveData
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3lib.utils.BigDec
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.common.*
import com.sonsofcrypto.web3wallet.android.common.extensions.annotatedStringFootnote
import com.sonsofcrypto.web3wallet.android.common.extensions.drawableResource
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.ui.*
import com.sonsofcrypto.web3walletcore.common.viewModels.CurrencyAmountPickerViewModel
import com.sonsofcrypto.web3walletcore.extensions.App
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.currencySwap.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapPresenterEvent.CurrencyFromChanged
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapViewModel.ApproveState
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapViewModel.ButtonState
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
                .padding(theme().shapes.padding),
            horizontalAlignment = Alignment.CenterHorizontally,
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
                        value = updateTextFieldValueSelection(value, newTextFieldValue, newValue)
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
                W3WSpacerVertical(theme().shapes.padding.half.half)
                SwapIndicatorElement(isCalculating = it.isCalculating) {
                    value = TextFieldValue("")
                    presenter.handle(CurrencySwapPresenterEvent.SwapFlip)
                }
                W3WSpacerVertical(theme().shapes.padding.half.half)
                W3WCurrencyView(viewModel = it.currencyTo,) {
                    presenter.handle(CurrencySwapPresenterEvent.CurrencyToTapped)
                }
                W3WSpacerVertical()
                SwapProviderRow(
                    viewModel = it.currencySwapProviderViewModel,
                    onClick = { showUnderConstruction = true }
                )
                W3WSpacerVertical(theme().shapes.padding.half)
                SwapPriceRow(
                    viewModel = it.currencySwapPriceViewModel
                )
                W3WSpacerVertical(theme().shapes.padding.half)
                SwapSlippageRow(
                    viewModel = it.currencySwapSlippageViewModel,
                    onClick = { showUnderConstruction = true }
                )
                W3WSpacerVertical(theme().shapes.padding.half)
                W3WNetworkFeeRowView(
                    viewModel = it.currencyNetworkFeeViewModel,
                    onClick = { showUnderConstruction = true }
                )
                approvalState(it)?.let { approvalState ->
                    W3WSpacerVertical()
                    SwapApproveButton(approvalState)
                }
                W3WSpacerVertical()
                SwapButton(it)
            }
            if (showUnderConstruction) {
                W3WUnderConstructionAlert { showUnderConstruction = false }
            }
        }
    }

    /** This method updates the selection (TextRange) so the cursor is at the correct position
     *  since sometimes we modify the (newValue) string result of some validation. */
    private fun updateTextFieldValueSelection(
        value: TextFieldValue,
        newTextFieldValue: TextFieldValue,
        newValue: String,
    ): TextFieldValue =
        if (value.text.length + 2 == newValue.length) {
            TextFieldValue(newValue, TextRange(newValue.length))
        } else if (value.text == newValue && value.text != newTextFieldValue.text) {
            TextFieldValue(newValue, TextRange(value.selection.start))
        } else if (value.text.length == newValue.length && value.text != newValue) {
            TextFieldValue(newValue, TextRange(value.selection.start))
        } else {
            TextFieldValue(newValue, newTextFieldValue.selection)
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
    
    @Composable
    private fun SwapIndicatorElement(
        isCalculating: Boolean,
        onClick: () -> Unit
    ) {
        Row(
            modifier = Modifier
                .size(24.dp)
                .then(CardBackgroundModifier(theme().shapes.cornerRadiusSmall.half))
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = if (isCalculating) {->} else onClick,
                ),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (isCalculating) {
                W3WLoading(
                    modifier = Modifier.size(16.dp),
                    strokeWidth = 2.dp,
                    strokeCap = StrokeCap.Butt,
                )
            } else {
                Icon(
                    Icons.Default.KeyboardArrowDown,
                    contentDescription = "swap",
                    tint = theme().colors.textPrimary,
                )
            }
        }
    }

    @Composable
    private fun SwapProviderRow(
        viewModel: CurrencySwapProviderViewModel,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            W3WText(
                text = Localized("currencySwap.cell.provider"),
                style = theme().fonts.footnote,
                modifier = Modifier.weight(1.0f),
            )
            W3WButtonSecondarySmall(
                title = viewModel.name.firstLetterCapital,
                onClick = onClick,
            )
        }
    }

    @Composable
    private fun SwapPriceRow(viewModel: CurrencySwapPriceViewModel) {
        Row(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            W3WText(
                text = Localized("currencySwap.cell.price"),
                style = theme().fonts.footnote,
                modifier = Modifier.weight(1.0f),
            )
            W3WText(
                text = viewModel.value.annotatedStringFootnote(),
            )
        }
    }
    @Composable
    private fun SwapSlippageRow(
        viewModel: CurrencySwapSlippageViewModel,
        onClick: () -> Unit,
    ) {
        Row(
            modifier = Modifier
                .padding(start = theme().shapes.padding, end = theme().shapes.padding)
        ) {
            W3WText(
                text = Localized("currencySwap.cell.slippage"),
                style = theme().fonts.footnote,
                modifier = Modifier.weight(1.0f),
            )
            W3WButtonSecondarySmall(
                title = viewModel.value,
                onClick = onClick,
            )
        }
    }

    private fun approvalState(viewModel: CurrencySwapViewModel.SwapData): ApproveState? {
        return when (viewModel.approveState) {
            ApproveState.APPROVE -> ApproveState.APPROVE
            ApproveState.APPROVING -> ApproveState.APPROVING
            ApproveState.APPROVED -> null
        }
    }

    @Composable
    private fun SwapApproveButton(viewModel: ApproveState) {
        when (viewModel) {
            ApproveState.APPROVE -> {
                W3WButtonPrimary(
                    title = Localized("currencySwap.cell.button.state.approve"),
                    onClick = {
                        presenter.handle(CurrencySwapPresenterEvent.Approve)
                    }
                )
            }
            ApproveState.APPROVING -> {
                W3WButtonPrimary(
                    title = Localized("currencySwap.cell.button.state.approving"),
                    isLoading = true,
                    onClick = {
                        presenter.handle(CurrencySwapPresenterEvent.Approve)
                    }
                )
            }
            ApproveState.APPROVED -> {}
        }
    }

    @Composable
    private fun SwapButton(viewModel: CurrencySwapViewModel.SwapData) {
        when (val buttonState = viewModel.buttonState) {
            is ButtonState.Loading -> {
                W3WButtonPrimary(
                    title = Localized("currencySwap.cell.button.state.swap"),
                    onRightIcon = { onRightSwapIcon() },
                    isEnabled = false,
                    isLoading = true,
                )
            }
            is ButtonState.Invalid -> {
                W3WButtonPrimary(
                    title = buttonState.text,
                    onRightIcon = { onRightSwapIcon() },
                    isEnabled = false,
                )
            }
            is ButtonState.Swap -> {
                W3WButtonPrimary(
                    title = Localized("currencySwap.cell.button.state.swap"),
                    isEnabled = viewModel.approveState == ApproveState.APPROVED,
                    onRightIcon = { onRightSwapIcon() },
                    onClick = {
                        presenter.handle(CurrencySwapPresenterEvent.Review)
                    }
                )
            }
            is ButtonState.SwapAnyway -> {
                W3WButtonPrimary(
                    title = buttonState.text,
                    isEnabled = viewModel.approveState == ApproveState.APPROVED,
                    isDestructive = true,
                    onRightIcon = { onRightSwapIcon() },
                    onClick = {
                        presenter.handle(CurrencySwapPresenterEvent.Review)
                    }
                )
            }
        }
    }

    @Composable
    fun onRightSwapIcon() {
        Image(
            painter = painterResource(id = R.drawable.uniswap_icon),
            contentDescription = "uniswap",
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
        )
    }
}

private val CurrencySwapViewModel.data: CurrencySwapViewModel.SwapData? get() {
    val item = items.firstOrNull() ?: return null
    return when (item) {
        is CurrencySwapViewModel.Item.Swap -> { item.swap }
        else -> { null }
    }
}