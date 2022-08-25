// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum TokenSendPresenterEvent {
    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case saveAddress
    case selectToken
    case tokenChanged(to: BigInt)
    case feeChanged(to: String)
    case qrCodeScan
    case feeTapped
    case review
}

protocol TokenSendPresenter: AnyObject {
    func present()
    func handle(_ event: TokenSendPresenterEvent)
}

final class DefaultTokenSendPresenter {
    private weak var view: TokenSendView?
    private let interactor: TokenSendInteractor
    private let wireframe: TokenSendWireframe
    private let context: TokenSendWireframeContext
    
    private var sendTapped = false
    private var address: String?
    private var token: Web3Token!
    private var amount: BigInt?
    private var fee: Web3NetworkFee = .low
    
    private var items = [TokenSendViewModel.Item]()
    private var fees = [Web3NetworkFee]()

    init(
        view: TokenSendView,
        interactor: TokenSendInteractor,
        wireframe: TokenSendWireframe,
        context: TokenSendWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
        
        loadContext()
    }
}

extension DefaultTokenSendPresenter: TokenSendPresenter {

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
                        tokenSymbolIconName: interactor.tokenIconName(for: token),
                        tokenSymbol: token.symbol.uppercased(),
                        tokenMaxAmount: token.balance,
                        tokenMaxDecimals: token.decimals,
                        currencyTokenPrice: token.usdPrice,
                        shouldUpdateTextFields: false,
                        shouldBecomeFirstResponder: false,
                        networkName: token.network.name
                    )
                ),
                .send(
                    .init(
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: makeEstimatedFee(),
                            feeType: makeFeeType()
                        ),
                        buttonState: .ready
                    )
                )
            ]
        )
    }

    func handle(_ event: TokenSendPresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.dismiss()
        case .qrCodeScan:
            view?.dismissKeyboard()
            let onQRCodeScanned = makeOnQRCodeScanned()
            wireframe.navigate(
                to: .qrCodeScan(
                    network: token.network,
                    onCompletion: onQRCodeScanned
                )
            )
            
        case .selectToken:
            wireframe.navigate(
                to: .selectToken(
                    selectedToken: token,
                    onCompletion: makeOnTokenToSelected()
                )
            )
        case .saveAddress:
            wireframe.navigate(to: .underConstructionAlert)
        case let .addressChanged(address):
            guard !isAddress(address: address, equalTo: context.addressTo) else { return }
            if
                let currentAddress = self.address,
                let formattedAddress = formattedAddress,
                formattedAddress.hasPrefix(address),
                formattedAddress.count == (address.count + 1)
            {
                updateAddress(with: String(currentAddress.prefix(currentAddress.count - 1)))
            } else {
                let isValid = interactor.isAddressValid(address: address, network: token.network)
                updateView(
                    address: address,
                    shouldTokenBecomeFirstResponder: isValid
                )
            }
            
        case .pasteAddress:
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = interactor.isAddressValid(address: clipboard, network: token.network)
            guard isValid else { return }
            updateView(
                address: clipboard,
                shouldTokenBecomeFirstResponder: isValid
            )
            
        case let .tokenChanged(amount):
            updateView(
                amount: amount,
                shouldTokenUpdateTextFields: false
            )
            
        case let .feeChanged(identifier):
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            updateCTA()
            
        case .feeTapped:
            view?.presentFeePicker(
                with: makeFees()
            )
            
        case .review:
            sendTapped = true
            let isValidAddress = interactor.isAddressValid(
                address: address ?? "",
                network: token.network
            )
            guard let address = address, isValidAddress  else {
                updateView(shouldAddressBecomeFirstResponder: true)
                return
            }
            guard let amount = amount, token.balance >= amount, amount > .zero else {
                updateView(shouldTokenBecomeFirstResponder: true)
                return
            }
            guard let walletAddress = interactor.walletAddress else { return }
            
            view?.dismissKeyboard()
                        
            wireframe.navigate(
                to: .confirmSend(
                    dataIn: .init(
                        token: makeConfirmationSendToken(),
                        destination: makeConfirmationSendDestination(from: walletAddress, to: address),
                        estimatedFee: makeConfirmationSendEstimatedFee()
                    )
                )
            )
        }
    }
}

private extension DefaultTokenSendPresenter {
    
    func isAddress(address: String, equalTo addressTo: String?) -> Bool {
        
        guard let addressTo = addressTo else { return false }
        let addressToCompare = interactor.addressFormattedShort(
            address: addressTo,
            network: token.network
        )
        return address == addressToCompare
    }
    
    func makeConfirmationSendEstimatedFee() -> Web3NetworkFee {
        switch fee {
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
    
    func makeConfirmationSendToken() -> ConfirmationWireframeContext.SendContext.Token {
        .init(
            iconName: interactor.tokenIconName(for: token),
            token: token,
            value: amount ?? .zero
        )
    }
    
    func makeConfirmationSendDestination(
        from walletAddress: String,
        to address: String
    ) -> ConfirmationWireframeContext.SendContext.Destination {
        .init(
            from: walletAddress,
            to: address
        )
    }
    
    func loadContext() {
        address = context.addressTo
        token = context.web3Token ?? interactor.defaultToken
    }
    
    func makeOnTokenToSelected() -> (Web3Token) -> Void {
        {
            [weak self] token in
            guard let self = self else { return }
            self.token = token
            let newAmount = BigInt.min(left: self.amount ?? .zero, right: token.balance)
            self.updateToken(with: newAmount, shouldUpdateTextFields: true)
        }
    }
    
    func updateView(with items: [TokenSendViewModel.Item]) {
        view?.update(
            with: .init(
                title: Localized("tokenSend.title", arg: token.symbol),
                items: items
            )
        )
    }
    
    func makeOnQRCodeScanned() -> (String) -> Void {
        { [weak self] address in
            
            guard let self = self else { return }
            self.updateAddress(with: address)
        }
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
        if !address.contains("...") {
            self.address = address
        }
        
        let isValid = interactor.isAddressValid(
            address: self.address ?? "",
            network: token.network
        )
                
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
        guard interactor.isAddressValid(address: address, network: token.network) else { return nil }
        return interactor.addressFormattedShort(
            address: address,
            network: token.network
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
                        tokenSymbolIconName: interactor.tokenIconName(for: token),
                        tokenSymbol: token.symbol.uppercased(),
                        tokenMaxAmount: token.balance,
                        tokenMaxDecimals: token.decimals,
                        currencyTokenPrice: token.usdPrice,
                        shouldUpdateTextFields: shouldUpdateTextFields,
                        shouldBecomeFirstResponder: shouldBecomeFirstResponder,
                        networkName: token.network.name
                    )
                )
            ]
        )
    }
    
    func updateCTA() {
        let isValidAddress = interactor.isAddressValid(
            address: address ?? "",
            network: token.network
        )
        let buttonState: TokenSendViewModel.Send.State
        if !sendTapped {
            buttonState = .ready
        } else if !isValidAddress {
            buttonState = .invalidDestination
        } else if (amount ?? .zero) == .zero {
            buttonState = .insufficientFunds
        } else if (amount ?? .zero) > token.balance {
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
                            estimatedFee: makeEstimatedFee(),
                            feeType: makeFeeType()
                        ),
                        buttonState: buttonState
                    )
                )
            ]
        )
    }
    
    func makeEstimatedFee() -> String {
        let amountInUSD = interactor.networkFeeInUSD(network: token.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: token.network, fee: fee)
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatStringCurrency()) ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatStringCurrency()) ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func makeFees() -> [FeesPickerViewModel] {
        
        let fees = interactor.networkFees(network: token.network)
        self.fees = fees
        return fees.compactMap { [weak self] in
            guard let self = self else { return nil }
            return .init(
                id: $0.rawValue,
                name: $0.name,
                value: self.interactor.networkFeeInNetworkToken(
                    network: token.network,
                    fee: $0
                )
            )
        }
    }
    
    func makeFeeType() -> TokenNetworkFeeViewModel.FeeType {
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
