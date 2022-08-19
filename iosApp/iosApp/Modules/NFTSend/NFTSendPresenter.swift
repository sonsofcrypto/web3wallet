// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NFTSendPresenterEvent {

    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case saveAddress
    case feeChanged(to: String)
    case qrCodeScan
    case feeTapped
    case review
}

protocol NFTSendPresenter: AnyObject {

    func present()
    func handle(_ event: NFTSendPresenterEvent)
}

final class DefaultNFTSendPresenter {

    private weak var view: NFTSendView?
    private let interactor: NFTSendInteractor
    private let wireframe: NFTSendWireframe
    private let context: NFTSendWireframeContext
    
    private var sendTapped = false
    private var address: String?
    private var fee: Web3NetworkFee = .low
    
    private var items = [NFTSendViewModel.Item]()
    private var fees = [Web3NetworkFee]()

    init(
        view: NFTSendView,
        interactor: NFTSendInteractor,
        wireframe: NFTSendWireframe,
        context: NFTSendWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
        
        
    }
}

extension DefaultNFTSendPresenter: NFTSendPresenter {

    func present() {
        
        updateView(
            with: [
                .nft(context.nftItem),
                .address(
                    .init(
                        value: nil,
                        isValid: false,
                        becomeFirstResponder: true
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

    func handle(_ event: NFTSendPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()

        case .qrCodeScan:
            
            view?.dismissKeyboard()
            let onQRCodeScanned = makeOnQRCodeScanned()
            wireframe.navigate(
                to: .qrCodeScan(
                    network: context.network,
                    onCompletion: onQRCodeScanned
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
                
                updateAddress(with: String(currentAddress.prefix(currentAddress.count - 1)))
            } else {
                let isValid = interactor.isAddressValid(address: address, network: context.network)
                updateView(
                    address: address,
                    shouldTokenBecomeFirstResponder: isValid
                )
            }
            
        case .pasteAddress:
            
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = interactor.isAddressValid(address: clipboard, network: context.network)
            guard isValid else { return }
            updateView(
                address: clipboard,
                shouldTokenBecomeFirstResponder: isValid
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
                network: context.network
            )
            guard let address = address, isValidAddress  else {
                updateView(
                    shouldAddressBecomeFirstResponder: true
                )
                return
            }
                                    
            wireframe.navigate(
                to: .confirmSendNFT(
                    dataIn: .init(
                        nftItem: context.nftItem,
                        destination: makeConfirmationSendNFTDestination(to: address),
                        estimatedFee: makeConfirmationSendNFTEstimatedFee()
                    )
                )
            )
        }
    }
}

private extension DefaultNFTSendPresenter {
    
    func makeConfirmationSendNFTEstimatedFee() -> Web3NetworkFee {
        
        switch fee {
            
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
    
    func makeConfirmationSendNFTDestination(
        to address: String
    ) -> ConfirmationWireframeContext.SendNFTContext.Destination {
        
        .init(
            from: interactor.addressFormattedShort(
                address: interactor.walletAddress ?? "",
                network: context.network
            ),
            to: interactor.addressFormattedShort(
                address: address,
                network: context.network
            )
        )
    }
    
    func updateView(with items: [NFTSendViewModel.Item]) {
        
        view?.update(
            with: .init(
                title: Localized("nftSend.title"),
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
        amount: Double? = nil,
        shouldTokenUpdateTextFields: Bool = false,
        shouldTokenBecomeFirstResponder: Bool = false
    ) {
        
        updateAddress(
            with: address ?? self.address ?? "",
            becomeFirstResponder: shouldAddressBecomeFirstResponder
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
            network: context.network
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
        
        guard interactor.isAddressValid(address: address, network: context.network) else { return nil }
        
        return interactor.addressFormattedShort(
            address: address,
            network: context.network
        )
    }

    func updateCTA() {
        
        let isValidAddress = interactor.isAddressValid(
            address: address ?? "",
            network: context.network
        )
        
        let buttonState: NFTSendViewModel.Send.State
        if !sendTapped {
            buttonState = .ready
        } else if !isValidAddress {
            buttonState = .invalidDestination
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
        
        let amountInUSD = interactor.networkFeeInUSD(network: context.network, fee: fee)
        let timeInSeconds = interactor.networkFeeInSeconds(network: context.network, fee: fee)
        
        let min: Double = Double(timeInSeconds) / Double(60)
        if min > 1 {
            return "\(amountInUSD.formatStringCurrency()) ~ \(min.toString(decimals: 0)) \(Localized("min"))"
        } else {
            return "\(amountInUSD.formatStringCurrency()) ~ \(timeInSeconds) \(Localized("sec"))"
        }
    }
    
    func makeFees() -> [FeesPickerViewModel] {
        
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
