package com.sonsofcrypto.web3walletcore.modules.currencySwap

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.formatters.Formatters.Output.Normal
import com.sonsofcrypto.web3lib.formatters.FormattersOutput
import com.sonsofcrypto.web3lib.services.uniswap.UniswapEvent
import com.sonsofcrypto.web3lib.types.Currency
import com.sonsofcrypto.web3lib.types.NetworkFee
import com.sonsofcrypto.web3lib.utils.*
import com.sonsofcrypto.web3walletcore.common.viewModels.*
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.extensions.toNetworkFeeViewModel
import com.sonsofcrypto.web3walletcore.modules.confirmation.ConfirmationWireframeContext
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapInteractorOutputAmountState.LOADING
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapInteractorSwapState.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapPresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapViewModel.ApproveState.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapViewModel.ButtonState.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframeDestination.*
import com.sonsofcrypto.web3walletcore.modules.currencySwap.CurrencySwapWireframeDestination.Dismiss
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

sealed class CurrencySwapPresenterEvent {
    object LimitSwapTapped: CurrencySwapPresenterEvent()
    object CurrencyFromTapped: CurrencySwapPresenterEvent()
    data class CurrencyFromChanged(val value: BigInt): CurrencySwapPresenterEvent()
    object CurrencyToTapped: CurrencySwapPresenterEvent()
    object SwapFlip: CurrencySwapPresenterEvent()
    object ProviderTapped: CurrencySwapPresenterEvent()
    object SlippageTapped: CurrencySwapPresenterEvent()
    data class NetworkFeeChanged(val value: NetworkFee): CurrencySwapPresenterEvent()
    object NetworkFeeTapped: CurrencySwapPresenterEvent()
    object Approve: CurrencySwapPresenterEvent()
    object Review: CurrencySwapPresenterEvent()
    object Dismiss: CurrencySwapPresenterEvent()
}

interface CurrencySwapPresenter {
    fun present()
    fun handle(event: CurrencySwapPresenterEvent)
    fun releaseResources()
}

class DefaultCurrencySwapPresenter(
    private val view: WeakRef<CurrencySwapView>?,
    private val wireframe: CurrencySwapWireframe,
    private val interactor: CurrencySwapInteractor,
    private val context: CurrencySwapWireframeContext,
): CurrencySwapPresenter, CurrencyInteractorLister {
    private var currencyFrom = context.currencyFrom ?: interactor.defaultCurrencyFrom(context.network)
    private var amountFrom: BigInt? = null
    private var currencyTo = context.currencyTo ?: interactor.defaultCurrencyTo(context.network)
    private var amountTo: BigInt? = null
    private var invalidQuote: Boolean = false
    private var networkFees: List<NetworkFee> = interactor.networkFees(context.network)
    private var networkFee: NetworkFee? = networkFees.firstOrNull()
    private val priceImpactWarningThreashold = 0.1
    private val bgScope = CoroutineScope(bgDispatcher)
    private val uiScope = CoroutineScope(uiDispatcher)

    init {
        interactor.add(this)
    }

    override fun present() { updateView() }

    override fun handle(event: CurrencySwapPresenterEvent) {
        when (event) {
            is LimitSwapTapped -> wireframe.navigate(UnderConstructionAlert)
            is CurrencyFromTapped -> wireframe.navigate(
                SelectCurrencyFrom { onCurrencyFromChanged(it) }
            )
            is CurrencyFromChanged -> {
                updateView()
                getQuote(event.value)
            }
            is CurrencyToTapped -> wireframe.navigate(
                SelectCurrencyTo { onCurrencyToChanged(it) }
            )
            is SwapFlip -> flipCurrencies()
            is ProviderTapped -> wireframe.navigate(UnderConstructionAlert)
            is SlippageTapped -> wireframe.navigate(UnderConstructionAlert)
            is NetworkFeeChanged -> {
                networkFee = event.value
                updateView()
            }
            is NetworkFeeTapped -> view?.get()?.presentNetworkFeePicker(networkFees, networkFee)
            is Approve -> confirmSwapApprovalIfNeeded()
            is Review -> reviewSwap()
            is CurrencySwapPresenterEvent.Dismiss -> wireframe.navigate(Dismiss)
        }
    }

    override fun releaseResources() {
        interactor.remove(this)
    }

    override fun handle(event: UniswapEvent) {
        if (!interactor.isCurrentQuote(currencyFrom, currencyTo, amountFrom ?: BigInt.zero))
            return
        invalidQuote = false
        updateView()
    }

    private fun updateView(
        updateTextField: Boolean = false,
        becomeFirstResponder: Boolean = false,
    ) {
        if (!invalidQuote) { amountTo = interactor.outputAmount }
        uiScope.launch {
            view?.get()?.update(viewModel(updateTextField, becomeFirstResponder))
        }
    }

    private fun viewModel(
        updateTextField: Boolean = false,
        becomeFirstResponder: Boolean = false,
    ): CurrencySwapViewModel {
        val data = CurrencySwapViewModel.SwapData(
            currencyFromViewModel(updateTextField, becomeFirstResponder),
            currencyToViewModel(),
            currencySwapProviderViewModel(),
            currencySwapPriceViewModel(),
            currencySwapSlippageViewModel(),
            networkFeeViewModel(),
            isCalculating,
            selectedProviderIconName,
            approveState(),
            buttonState(),
        )
        return CurrencySwapViewModel(
            Localized("currencySwap.title"),
            listOf(CurrencySwapViewModel.Item.Swap(data))
        )
    }

    private fun currencyFromViewModel(
        updateTextField: Boolean = false,
        becomeFirstResponder: Boolean = false
    ): CurrencyAmountPickerViewModel =
        CurrencyAmountPickerViewModel(
            amount = amountFrom,
            symbolIconName = currencyFrom.iconName,
            symbol = currencyFrom.symbol.uppercase(),
            maxAmount = currencyFromBalance,
            maxDecimals = currencyFrom.decimals(),
            fiatPrice = interactor.fiatPrice(currencyFrom),
            updateTextField = updateTextField,
            becomeFirstResponder = becomeFirstResponder,
            networkName = context.network.name,
            currency = currencyFrom
        )

    private val currencyFromBalance: BigInt get() =
        interactor.balance(currencyFrom, context.network)

    private fun currencyToViewModel(): CurrencyAmountPickerViewModel =
        CurrencyAmountPickerViewModel(
            amount = amountTo,
            symbolIconName = currencyTo.iconName,
            symbol = currencyTo.symbol.uppercase(),
            maxAmount = currencyToBalance,
            maxDecimals = currencyTo.decimals(),
            fiatPrice = interactor.fiatPrice(currencyTo),
            updateTextField = true,
            becomeFirstResponder = false,
            networkName = context.network.name,
            currency = currencyTo
        )

    private val currencyToBalance: BigInt get() =
        interactor.balance(currencyTo, context.network)

    private fun currencySwapProviderViewModel(): CurrencySwapProviderViewModel =
        CurrencySwapProviderViewModel(
            selectedProviderIconName,
            selectedProviderName,
        )

    private val selectedProviderIconName: String get() = "${selectedProviderName}-provider"
    private val selectedProviderName: String get() = "uniswap"

    private fun currencySwapPriceViewModel(): CurrencySwapPriceViewModel =
        CurrencySwapPriceViewModel(swapPrice)

    private val swapPrice: List<Formatters.Output> get() {
        val symbolFrom = currencyFrom.symbol.uppercase()
        val symbolTo = currencyTo.symbol.uppercase()
        val fiatFrom = interactor.fiatPrice(currencyFrom)
        val fiatTo = interactor.fiatPrice(currencyTo)
        if (fiatFrom == 0.toDouble() || fiatTo == 0.toDouble()) return listOf(Normal("-"))
        else if (fiatFrom == 0.toDouble()) return listOf(Normal("? $symbolFrom ≈ 1 $symbolTo" ))
        else if (fiatTo == 0.toDouble()) return listOf(Normal("1 $symbolFrom ≈ ? $symbolTo" ))
        val output = mutableListOf<Formatters.Output>(Normal("1 $symbolFrom ≈ "))
        val swapPriceString = BigDec.from(fiatFrom/fiatTo).toDecimalString()
        output.addAll(FormattersOutput().convert(swapPriceString, 10u, false))
        output.add(Normal(" $symbolTo"))
        return output
    }

    private fun currencySwapSlippageViewModel(): CurrencySwapSlippageViewModel =
        CurrencySwapSlippageViewModel(selectedSlippage)

    private val selectedSlippage: String get() = "1%"

    private fun networkFeeViewModel(): NetworkFeeViewModel {
        val mul = interactor.fiatPrice(context.network.nativeCurrency)
        return networkFee?.toNetworkFeeViewModel(mul) ?: emptyNetworkFeeViewModel
    }

    private val emptyNetworkFeeViewModel: NetworkFeeViewModel get() =
        NetworkFeeViewModel("-", listOf(), listOf(), listOf())

    private val isCalculating: Boolean get() =
        interactor.outputAmountState == LOADING && amountFromGreaterThanZero

    private fun approveState(): CurrencySwapViewModel.ApproveState {
        // NOTE: This simply hides the Approve button since we won't be able to swap anyway
        if (!amountFromGreaterThanZero || insufficientFunds) return APPROVED

        // NOTE: Here we are still calculating a quote, so we don't want to show the approve
        // button yet in case that we need to, we will do once the quote is retrieved
        if (isCalculating) return APPROVED

        // NOTE: Here we know that there is no pool available to do the swap, so we do not
        // show approved since you would not be able to swap anyway
        if (interactor.swapState == NOT_AVAILABLE) return APPROVED
        if (interactor.swapState == NO_POOLS) return APPROVED

        return when (interactor.approvingState) {
            CurrencySwapInteractorApprovalState.APPROVE -> { APPROVE }
            CurrencySwapInteractorApprovalState.APPROVING -> { APPROVING }
            CurrencySwapInteractorApprovalState.APPROVED -> { APPROVED }
        }
    }

    private val amountFromGreaterThanZero: Boolean get() =
        amountFrom?.isGreaterThan(BigInt.zero) ?: false

    private val insufficientFunds: Boolean get() {
        return (amountFrom ?: BigInt.zero).isGreaterThan(currencyFromBalance)
                || currencyFromBalance == BigInt.zero
    }

    private fun buttonState(): CurrencySwapViewModel.ButtonState {
        if (!amountFromGreaterThanZero) return Invalid(Localized("currencySwap.enterAmount"))
        if (insufficientFunds)
            return Invalid(
                Localized("currencySwap.insufficientBalance", currencyFrom.symbol.uppercase())
            )
        if (isCalculating) return Loading
        return when (interactor.swapState) {
            NO_POOLS -> Invalid(Localized("currencySwap.noPoolsFound"))
            NOT_AVAILABLE -> Invalid(Localized("currencySwap.noPoolsFound"))
            SWAP -> {
                if (priceImpact >= priceImpactWarningThreashold) {
                    SwapAnyway(Localized("currencySwap.swapAnyway", (priceImpact * 100).toString()))
                }
                Swap
            }
        }
    }

    private val priceImpact: Double get() {
        val amountFrom = amountFrom ?: return 0.toDouble()
        val amountTo = amountTo ?: return 0.toDouble()
        val fromFiatValue = Formatters.crypto(
            amountFrom, currencyFrom.decimals(), interactor.fiatPrice(currencyFrom)
        )
        val toFiatValue = Formatters.crypto(
            amountTo, currencyTo.decimals(), interactor.fiatPrice(currencyTo)
        )
        return 1 - (toFiatValue/fromFiatValue)
    }

    private fun onCurrencyFromChanged(currency: Currency) {
        currencyFrom = currency
        amountFrom = BigInt.zero
        amountTo = BigInt.zero
        invalidQuote = true
        getQuote(BigInt.zero)
        updateView(updateTextField = true, becomeFirstResponder = true)
    }

    private fun onCurrencyToChanged(currency: Currency) {
        currencyTo = currency
        getQuote(amountFrom ?: BigInt.zero)
    }

    private fun getQuote(amount: BigInt) {
        amountFrom = amount
        interactor.getQuote(currencyFrom, currencyTo, amountFrom!!)
    }

    private fun flipCurrencies() {
        amountFrom = BigInt.zero
        amountTo = BigInt.zero
        invalidQuote = true
        val currentCurrencyFrom = currencyFrom
        val currentCurrencyTo = currencyTo
        currencyFrom = currentCurrencyTo
        currencyTo = currentCurrencyFrom
        getQuote(amountFrom ?: BigInt.zero)
        updateView(updateTextField =  true)
    }

    private fun confirmSwapApprovalIfNeeded() {
        val networkFee = networkFee ?: return
        if (approveState() != APPROVE) return
        wireframe.navigate(
            ConfirmApproval(
                currencyTo,
                { password, salt ->
                    bgScope.launch {
                        interactor.approveSwap(context.network, currencyTo, password, salt)
                    }
                },
                networkFee,
            )
        )
    }

    private fun reviewSwap() {
        if (!amountFromGreaterThanZero) {
            return updateView(updateTextField = true, becomeFirstResponder = true)
        }
        val amountFrom = amountFrom ?: BigInt.zero
        val amountTo = amountTo ?: BigInt.zero
        val networkFee = networkFee ?: return
        if (!currencyFromBalance.isGreaterThan(amountFrom)) return
        if (interactor.swapState != SWAP) return
        val context = ConfirmationWireframeContext.SwapContext(
            context.network,
            ConfirmationWireframeContext.SwapContext.Provider(
                selectedProviderIconName,
                selectedProviderName,
                selectedSlippage
            ),
            amountFrom,
            amountTo,
            currencyFrom,
            currencyTo,
            networkFee,
            interactor.swapService()
        )
        wireframe.navigate(ConfirmSwap(ConfirmationWireframeContext.Swap(context)))
    }
}
