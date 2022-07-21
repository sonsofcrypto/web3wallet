// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSendPresenterEvent {

    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case saveAddress
    case selectToken
    case tokenChanged(to: Double)
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
    
    private var address: String?
    private var token: Web3Token!
    private var amount: Double?
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
        
        loadToken()
    }
}

extension DefaultTokenSendPresenter: TokenSendPresenter {

    func present() {
        
        updateView(
            with: [
                .address(
                    .init(
                        value: nil,
                        isValid: false
                    )
                ),
                .token(
                    .init(
                        tokenAmount: nil,
                        tokenSymbolIcon: interactor.tokenIcon(for: token),
                        tokenSymbol: token.symbol.uppercased(),
                        tokenMaxAmount: token.balance,
                        tokenMaxDecimals: token.decimals,
                        currencyTokenPrice: token.usdPrice,
                        shouldUpdateTextFields: false,
                        shouldBecomeFirstResponder: true
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
                    onCompletion: makeOnTokenToSelected()
                )
            )
            
        case .saveAddress:
            
            wireframe.navigate(to: .underConstructionAlert)
            
        case let .addressChanged(address):
            
            if
                let currentAddress = self.address,
                let formattedAddress = formattedAddress,
                formattedAddress.hasPrefix(address),
                formattedAddress.count == (address.count + 1)
            {
                
                updateAddress(with: String(currentAddress.prefix(currentAddress.length - 1)))
            } else {
                updateAddress(with: address)
            }
            
        case .pasteAddress:
            
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = interactor.isAddressValid(address: clipboard, network: token.network)
            guard isValid else { return }
            updateAddress(with: clipboard)
            
        case let .tokenChanged(amount):
            
            updateToken(with: amount, shouldUpdateTextFields: false)
            
        case let .feeChanged(identifier):
            
            guard let fee = fees.first(where: { $0.rawValue == identifier }) else { return }
            self.fee = fee
            updateToken(with: amount ?? 0, shouldUpdateTextFields: false)
            
        case .feeTapped:
            
            view?.presentFeePicker(
                with: makeFees()
            )
            
        case .review:
            
            guard let address = address else { return }
            
            wireframe.navigate(
                to: .confirmSend(
                    dataIn: .init(
                        token: makeConfirmationSendToken(),
                        destination: makeConfirmationSendDestination(to: address),
                        estimatedFee: interactor.networkFeeInUSD(network: token.network, fee: fee)
                    ),
                    onSuccess: makeOnTokenTransactionSend()
                    
                )
            )
        }
    }
}

private extension DefaultTokenSendPresenter {
    
    func makeConfirmationSendToken() -> ConfirmationWireframeContext.SendContext.Token {
        
        .init(
            icon: interactor.tokenIcon(for: token),
            token: token,
            value: amount ?? 0
        )
    }
    
    func makeConfirmationSendDestination(
        to address: String
    ) -> ConfirmationWireframeContext.SendContext.Destination {
        
        // TODO: @Annon: Select current wallet addres
        let currentWalletAddress = "0xa7876hea0ba39494ce839613fffba74279579268"
        return .init(
            from: interactor.addressFormattedShort(
                address: currentWalletAddress,
                network: token.network
            ),
            to: interactor.addressFormattedShort(
                address: address,
                network: token.network
            )
        )
    }
    
    func makeOnTokenTransactionSend() -> () -> Void {
        
        {
            print("Transaction send!!!")
        }
    }

    func loadToken() {
        
        token = context.web3Token ?? interactor.defaultToken
    }
    
    func makeOnTokenToSelected() -> (Web3Token) -> Void {
        
        {
            [weak self] token in
            guard let self = self else { return }
            self.token = token
            let newAmount = min(self.amount ?? 0, token.balance)
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
    
    func updateAddress(with address: String) {
        
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
                        isValid: isValid
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
        with amount: Double,
        shouldUpdateTextFields: Bool
    ) {
        
        self.amount = amount
        
        let insufficientFunds = amount > token.balance
        
        updateView(
            with: [
                .token(
                    .init(
                        tokenAmount: amount,
                        tokenSymbolIcon: interactor.tokenIcon(for: token),
                        tokenSymbol: token.symbol.uppercased(),
                        tokenMaxAmount: token.balance,
                        tokenMaxDecimals: token.decimals,
                        currencyTokenPrice: token.usdPrice,
                        shouldUpdateTextFields: shouldUpdateTextFields,
                        shouldBecomeFirstResponder: false
                    )
                ),
                .send(
                    .init(
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: self.makeEstimatedFee(),
                            feeType: self.makeFeeType()
                        ),
                        buttonState: insufficientFunds ? .insufficientFunds : .ready
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
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatCurrency() ?? "") ~ \(timeInSeconds) \(Localized("sec"))"
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
