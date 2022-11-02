// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum CurrencySendPresenterEvent {
    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case saveAddress
    case selectCurrency
    case amountChanged(to: BigInt)
    case feeChanged(to: NetworkFee)
    case qrCodeScan
    case feeTapped
    case review
}

protocol CurrencySendPresenter: AnyObject {
    func present()
    func handle(_ event: CurrencySendPresenterEvent)
}

final class DefaultCurrencySendPresenter {
    private weak var view: CurrencySendView?
    private let wireframe: CurrencySendWireframe
    private let interactor: CurrencySendInteractor
    private let context: CurrencySendWireframeContext
    
    private var sendTapped = false
    private var address: String?
    private var currency: Currency!
    private var amount: BigInt?
    private var fee: NetworkFee?
    
    private var items = [CurrencySendViewModel.Item]()
    private var fees = [NetworkFee]()

    init(
        view: CurrencySendView,
        wireframe: CurrencySendWireframe,
        interactor: CurrencySendInteractor,
        context: CurrencySendWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
        loadContext()
    }
}

extension DefaultCurrencySendPresenter: CurrencySendPresenter {

    func present() {
        updateView(
            with: [
                .address(
                    .init(
                        placeholder: Localized("networkAddressPicker.to.address.placeholder", context.network.name),
                        value: formattedAddress ?? address,
                        isValid: false,
                        becomeFirstResponder: true
                    )
                ),
                .token(
                    .init(
                        amount: nil,
                        symbolIconName: currency.iconName,
                        symbol: currency.symbol.uppercased(),
                        maxAmount: currencyBalance,
                        maxDecimals: currency.decimalsUInt,
                        fiatPrice: currency.fiatPrice,
                        shouldUpdateTextFields: false,
                        shouldBecomeFirstResponder: false,
                        networkName: context.network.name
                    )
                ),
                .send(
                    .init(
                        networkFeeViewModel: .init(
                            estimatedFee: estimatedFee(),
                            feeName: feeName()
                        ),
                        buttonState: .ready
                    )
                )
            ]
        )
    }

    func handle(_ event: CurrencySendPresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.dismiss()
        case .qrCodeScan:
            view?.dismissKeyboard()
            wireframe.navigate(to: .qrCodeScan(network: context.network, onCompletion: onQRCodeScanned()))
        case .selectCurrency:
            wireframe.navigate(to: .selectCurrency(onCompletion: onCurrencySelected()))
        case .saveAddress:
            wireframe.navigate(to: .underConstructionAlert)
        case let .addressChanged(address):
            guard !isAddress(address: address, equalTo: context.address) else { return }
            if
                let currentAddress = self.address,
                let formattedAddress = formattedAddress,
                formattedAddress.hasPrefix(address),
                formattedAddress.count == (address.count + 1)
            {
                updateAddress(with: String(currentAddress.prefix(currentAddress.count - 1)))
            } else {
                let isValid = context.network.isValidAddress(input: address)
                updateView(
                    address: address,
                    shouldTokenBecomeFirstResponder: isValid
                )
            }
        case .pasteAddress:
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = context.network.isValidAddress(input: clipboard)
            guard isValid else { return }
            updateView(address: clipboard, shouldTokenBecomeFirstResponder: isValid)
        case let .amountChanged(amount):
            updateView(amount: amount, shouldTokenUpdateTextFields: false)
        case let .feeChanged(fee):
            self.fee = fee
            updateCTA()
        case .feeTapped:
            view?.presentFeePicker(with: fees)
        case .review:
            sendTapped = true
            let isValidAddress = context.network.isValidAddress(input: address ?? "")
            guard let address = address, isValidAddress  else {
                updateView(shouldAddressBecomeFirstResponder: true)
                return
            }
            let balance = interactor.balance(currency: currency, network: context.network)
            guard let amount = amount, balance >= amount, amount > .zero, let fee = fee else {
                updateView(shouldTokenBecomeFirstResponder: true)
                return
            }
            guard let walletAddress = interactor.walletAddress else { return }
            view?.dismissKeyboard()
            let context = ConfirmationWireframeContext.Send(
                data: .init(
                    network: context.network,
                    currency: currency,
                    amount: amount,
                    addressFrom: walletAddress,
                    addressTo: address,
                    networkFee: fee
                )
            )
            wireframe.navigate(to: .confirmSend(context: context))
        }
    }
}

private extension DefaultCurrencySendPresenter {
    
    var currencyBalance: BigInt {
        interactor.balance(currency: currency, network: context.network)
    }
    
    func isAddress(address: String, equalTo addressTo: String?) -> Bool {
        guard let addressTo = addressTo else { return false }
        let addressToCompare = Formatters.Companion.shared.networkAddress.format(
            address: addressTo, digits: 8, network: context.network
        )
        return address == addressToCompare
    }
    
    func loadContext() {
        address = context.address
        currency = context.currency ?? interactor.defaultCurrency(network: context.network)
        refreshFees()
    }
    
    func refreshFees() {
        fees = interactor.networkFees(network: context.network)
        guard fee == nil, !fees.isEmpty else { return }
        fee = fees[0]
    }
    
    func onCurrencySelected() -> (Currency) -> Void {
        {
            [weak self] currency in
            guard let self = self else { return }
            self.currency = currency
            let newBalance = self.interactor.balance(currency: currency, network: self.context.network)
            let newAmount = BigInt.min(left: self.amount ?? .zero, right: newBalance)
            self.updateToken(with: newAmount, shouldUpdateTextFields: true)
        }
    }
    
    func updateView(with items: [CurrencySendViewModel.Item]) {
        view?.update(
            with: .init(
                title: Localized("currencySend.title", currency.symbol.uppercased()),
                items: items
            )
        )
    }
    
    func onQRCodeScanned() -> (String) -> Void {
        { [weak self] address in self?.updateAddress(with: address) }
    }
    
    func updateView(
        address: String? = nil,
        shouldAddressBecomeFirstResponder: Bool = false,
        amount: BigInt? = nil,
        shouldTokenUpdateTextFields: Bool = false,
        shouldTokenBecomeFirstResponder: Bool = false
    ) {
        updateAddress(
            with: address ?? self.address ?? "",
            becomeFirstResponder: shouldAddressBecomeFirstResponder
        )
        updateToken(
            with: amount ?? self.amount ?? .zero,
            shouldUpdateTextFields: shouldTokenUpdateTextFields,
            shouldBecomeFirstResponder: shouldTokenBecomeFirstResponder
        )
        updateCTA()
    }
    
    func updateAddress(
        with address: String,
        becomeFirstResponder: Bool = false
    ) {
        if !address.contains("...") { self.address = address }
        let isValid = context.network.isValidAddress(input: self.address ?? "")
        updateView(
            with: [
                .address(
                    .init(
                        placeholder: Localized("networkAddressPicker.to.address.placeholder", context.network.name),
                        value: formattedAddress ?? address,
                        isValid: isValid,
                        becomeFirstResponder: becomeFirstResponder
                    )
                )
            ]
        )
    }
    
    var formattedAddress: String? {
        guard let address = address else { return nil }
        guard context.network.isValidAddress(input: address) else { return nil }
        return Formatters.Companion.shared.networkAddress.format(
            address: address, digits: 8, network: context.network
        )
    }

    func updateToken(
        with amount: BigInt,
        shouldUpdateTextFields: Bool,
        shouldBecomeFirstResponder: Bool = false
    ) {
        self.amount = amount
        updateView(
            with: [
                .token(
                    .init(
                        amount: amount,
                        symbolIconName: currency.iconName,
                        symbol: currency.symbol.uppercased(),
                        maxAmount: currencyBalance,
                        maxDecimals: currency.decimalsUInt,
                        fiatPrice: currency.fiatPrice,
                        shouldUpdateTextFields: shouldUpdateTextFields,
                        shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                        networkName: context.network.name
                    )
                )
            ]
        )
    }
    
    func updateCTA() {
        let isValidAddress = context.network.isValidAddress(input: address ?? "")
        let buttonState: CurrencySendViewModel.Send.State
        if !sendTapped {
            buttonState = .ready
        } else if !isValidAddress {
            buttonState = .invalidDestination
        } else if (amount ?? .zero) == .zero {
            buttonState = .insufficientFunds
        } else if (amount ?? .zero) > currencyBalance {
            buttonState = .insufficientFunds
        } else if (amount ?? .zero) == .zero {
            buttonState = .enterFunds
        } else {
            buttonState = .ready
        }
        updateView(
            with: [
                .send(
                    .init(
                        networkFeeViewModel: .init(
                            estimatedFee: estimatedFee(),
                            feeName: feeName()
                        ),
                        buttonState: buttonState
                    )
                )
            ]
        )
    }
    
    func estimatedFee() -> [Formatters.Output] {
        guard let fee = fee else { return [Formatters.OutputNormal(value: "-")] }
        var outputFormat = Formatters.Companion.shared.currency.format(
            amount: fee.amount, currency: fee.currency, style: Formatters.StyleCustom(maxLength: 10)
        )
        let min: Double = Double(fee.seconds) / Double(60)
        var value = ""
        if min > 1 {
            value = " ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            value = " ~ \(fee.seconds) \(Localized("sec"))"
        }
        outputFormat.append(
            Formatters.OutputNormal(value: value)
        )
        return outputFormat
    }
    
    func feeName() -> String {
        guard let fee = fee else { return "-" }
        return fee.name
    }
}
