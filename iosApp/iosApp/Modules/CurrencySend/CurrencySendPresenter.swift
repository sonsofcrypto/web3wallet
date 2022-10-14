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
    case currencyChanged(to: BigInt)
    case feeChanged(to: String)
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
    private var fee: Web3NetworkFee = .low
    
    private var items = [CurrencySendViewModel.Item]()
    private var fees = [Web3NetworkFee]()

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
                        value: formattedAddress ?? address,
                        isValid: false,
                        becomeFirstResponder: true
                    )
                ),
                .token(
                    .init(
                        tokenAmount: nil,
                        tokenSymbolIconName: currency.iconName,
                        tokenSymbol: currency.symbol.uppercased(),
                        tokenMaxAmount: currencyBalance,
                        tokenMaxDecimals: currency.decimalsUInt,
                        currencyTokenPrice: currency.fiatPrice,
                        shouldUpdateTextFields: false,
                        shouldBecomeFirstResponder: false,
                        networkName: context.network.name
                    )
                ),
                .send(
                    .init(
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: estimatedFee(),
                            feeType: feeType()
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
                let isValid = context.network.isValid(address: address)
                updateView(
                    address: address,
                    shouldTokenBecomeFirstResponder: isValid
                )
            }
        case .pasteAddress:
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = context.network.isValid(address: clipboard)
            guard isValid else { return }
            updateView(address: clipboard, shouldTokenBecomeFirstResponder: isValid)
        case let .currencyChanged(amount):
            updateView(amount: amount, shouldTokenUpdateTextFields: false)
        case let .feeChanged(identifier):
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            updateCTA()
        case .feeTapped:
            view?.presentFeePicker(with: _fees())
        case .review:
            sendTapped = true
            let isValidAddress = context.network.isValid(address: address ?? "")
            guard let address = address, isValidAddress  else {
                updateView(shouldAddressBecomeFirstResponder: true)
                return
            }
            let balance = interactor.balance(currency: currency, network: context.network)
            guard let amount = amount, balance >= amount, amount > .zero else {
                updateView(shouldTokenBecomeFirstResponder: true)
                return
            }
            guard let walletAddress = interactor.walletAddress else { return }
            view?.dismissKeyboard()
            wireframe.navigate(
                to: .confirmSend(
                    context: .init(
                        network: context.network,
                        currency: currency,
                        amount: amount,
                        addressFrom: walletAddress,
                        addressTo: address,
                        estimatedFee: confirmationSendEstimatedFee()
                    )
                )
            )
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
    
    func confirmationSendEstimatedFee() -> Web3NetworkFee {
        switch fee {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        }
    }
    
    func loadContext() {
        address = context.address
        currency = context.currency ?? interactor.defaultCurrency(network: context.network)
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
                title: Localized("tokenSend.title", currency.symbol.uppercased()),
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
        let isValid = context.network.isValid(address: self.address ?? "")
        updateView(
            with: [
                .address(
                    .init(
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
        guard context.network.isValid(address: address) else { return nil }
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
                        tokenAmount: amount,
                        tokenSymbolIconName: currency.iconName,
                        tokenSymbol: currency.symbol.uppercased(),
                        tokenMaxAmount: currencyBalance,
                        tokenMaxDecimals: currency.decimalsUInt,
                        currencyTokenPrice: currency.fiatPrice,
                        shouldUpdateTextFields: shouldUpdateTextFields,
                        shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                        networkName: context.network.name
                    )
                )
            ]
        )
    }
    
    func updateCTA() {
        let isValidAddress = context.network.isValid(address: address ?? "")
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
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: estimatedFee(),
                            feeType: feeType()
                        ),
                        buttonState: buttonState
                    )
                )
            ]
        )
    }
    
    func estimatedFee() -> String {
        let amountInUSD = interactor.networkFeeInUSD(network: context.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: context.network, fee: fee)
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatStringCurrency()) ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatStringCurrency()) ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func _fees() -> [FeesPickerViewModel] {
        let fees = interactor.networkFees(network: context.network)
        self.fees = fees
        return fees.compactMap { [weak self] in
            guard let self = self else { return nil }
            return .init(
                id: $0.rawValue,
                name: $0.name,
                value: self.interactor.networkFeeInNetworkToken(
                    network: context.network,
                    fee: $0
                )
            )
        }
    }
    
    func feeType() -> NetworkFeePickerViewModel.FeeType {
        switch fee {
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}

private extension Web3NetworkFee {
    var name: String {
        switch self {
        case .low:
            return Localized("low")
        case .medium:
            return Localized("medium")
        case .high:
            return Localized("high")
        }
    }
}
