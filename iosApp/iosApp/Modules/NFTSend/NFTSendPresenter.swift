// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum NFTSendPresenterEvent {
    case dismiss
    case addressChanged(to: String)
    case pasteAddress
    case saveAddress
    case feeChanged(to: NetworkFee)
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
    private let wireframe: NFTSendWireframe
    private let interactor: NFTSendInteractor
    private let context: NFTSendWireframeContext
    
    private var sendTapped = false
    private var address: String?
    private var fee: NetworkFee?

    private var items = [NFTSendViewModel.Item]()
    private var fees = [NetworkFee]()

    init(
        view: NFTSendView,
        wireframe: NFTSendWireframe,
        interactor: NFTSendInteractor,
        context: NFTSendWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
        refreshFees()
    }
}

extension DefaultNFTSendPresenter: NFTSendPresenter {

    func present() {
        updateView(
            with: [
                .nft(context.nftItem),
                .address(
                    .init(
                        placeholder: Localized("networkAddressPicker.to.address.placeholder", context.network.name),
                        value: nil,
                        isValid: false,
                        becomeFirstResponder: true
                    )
                ),
                .send(
                    .init(
                        tokenNetworkFeeViewModel: .init(
                            estimatedFee: estimatedFee(),
                            feeName: feeName()
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
            wireframe.navigate(
                to: .qrCodeScan(network: context.network, onCompletion: onQRCodeScanned())
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
                updateView(address: address)
            }
        case .pasteAddress:
            let clipboard = UIPasteboard.general.string ?? ""
            let isValid = context.network.isValidAddress(input: clipboard)
            guard isValid else { return }
            updateView(address: clipboard)
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
            guard let walletAddress = interactor.walletAddress, let fee = fee else { return }
            let context = ConfirmationWireframeContext.SendNFT(
                data: .init(
                    network: context.network,
                    addressFrom: walletAddress,
                    addressTo: address,
                    nftItem: context.nftItem,
                    networkFee: fee
                )
            )
            wireframe.navigate(to: .confirmSendNFT(context: context))
        }
    }
}

private extension DefaultNFTSendPresenter {
    
    func refreshFees() {
        fees = interactor.networkFees(network: context.network)
        guard fee == nil, !fees.isEmpty else { return }
        fee = fees[0]
    }
    
    func updateView(with items: [NFTSendViewModel.Item]) {
        view?.update(
            with: .init(
                title: Localized("nftSend.title"),
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
        amount: Double? = nil
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
            address: address,
            digits: 8,
            network: context.network
        )
    }

    func updateCTA() {
        let isValidAddress = context.network.isValidAddress(input: address ?? "")
        let buttonState: NFTSendViewModel.Send.State
        if !sendTapped { buttonState = .ready }
        else if !isValidAddress { buttonState = .invalidDestination }
        else { buttonState = .ready }
        updateView(
            with: [
                .send(
                    .init(
                        tokenNetworkFeeViewModel: .init(
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
