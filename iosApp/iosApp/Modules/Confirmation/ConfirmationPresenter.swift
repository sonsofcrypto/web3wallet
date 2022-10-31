// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum ConfirmationPresenterEvent {
    case confirm
    case txSuccessCTATapped
    case txSuccessCTASecondaryTapped
    case txFailedCTATapped
    case txFailedCTASecondaryTapped
    case dismiss
}

protocol ConfirmationPresenter {
    var contextType: ConfirmationWireframeContext.`Type` { get }
    func present()
    func handle(_ event: ConfirmationPresenterEvent)
}

final class DefaultConfirmationPresenter {
    private weak var view: ConfirmationView?
    private let wireframe: ConfirmationWireframe
    private let interactor: ConfirmationInteractor
    private let context: ConfirmationWireframeContext
    
    private var txHash: String?
    private var error: Error?
    
    init(
        view: ConfirmationView,
        wireframe: ConfirmationWireframe,
        interactor: ConfirmationInteractor,
        context: ConfirmationWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultConfirmationPresenter: ConfirmationPresenter {
    var contextType: ConfirmationWireframeContext.`Type` {
        context.type
    }

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: ConfirmationPresenterEvent) {
        switch event {
        case .confirm:
            switch context.type {
            case .send, .sendNFT, .cultCastVote, .approveUniswap, .swap:
                wireframe.navigate(to: .authenticate(authenticateContext()))
            }
        case .txSuccessCTATapped:
            switch context.type {
            case .send:
                view?.dismiss(animated: true) { [weak self] in
                    self?.wireframe.navigate(to: .account)
                }
            case .sendNFT:
                wireframe.navigate(to: .nftsDashboard)
            case .cultCastVote:
                wireframe.navigate(to: .cultProposals)
            case .swap, .approveUniswap:
                wireframe.dismiss()
            }
        case .txSuccessCTASecondaryTapped:
            guard let txHash = txHash else { return }
            wireframe.navigate(to: .viewEtherscan(txHash: txHash))
        case .txFailedCTATapped:
            wireframe.dismiss()
        case .txFailedCTASecondaryTapped:
            guard let error = error else { return }
            wireframe.navigate(to: .report(error: error))
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultConfirmationPresenter {
    
    func viewModel() -> ConfirmationViewModel {
        let content: ConfirmationViewModel.Content
        switch context.type {
        case let .swap(swapData):
            content = contentViewModel(forSwap: swapData)
        case let .send(sendData):
            content = contentViewModel(forSend: sendData)
        case let .sendNFT(sendNFTData):
            content = contentViewModel(forSendNFT: sendNFTData)
        case let .cultCastVote(cultCastVoteData):
            content = contentViewModel(forCultCastVote: cultCastVoteData)
        case let .approveUniswap(approveUniswapData):
            content = contentViewModel(forApproveUniswap: approveUniswapData)
        }
        return .init(title: titleViewModel(), content: content)
    }
    
    func titleViewModel() -> String {
        Localized("confirmation.\(context.type.localizedTag).title")
    }
    
    func contentViewModel(
        forSwap data: ConfirmationWireframeContext.SwapContext
    ) -> ConfirmationViewModel.Content {
        let fiatFromValue = (
            data.amountFrom.toBigDec(
                decimals: data.currencyFrom.decimalsUInt
            ).mul(
                value: data.currencyFrom.fiatPrice.bigDec
            ).mul(value: Double(100).bigDec) // this is because we want 2 decimals on currency
        ).toBigInt().formatStringCurrency()
        let currencyFrom = ConfirmationViewModel.SwapViewModel.Currency(
            iconName: data.currencyFrom.iconName,
            symbol: data.currencyFrom.symbol,
            value: currencyFormatted(data.currencyFrom, value: data.amountFrom),
            usdValue: fiatFromValue
        )
        let fiatToValue = (
            data.amountTo.toBigDec(
                decimals: data.currencyTo.decimalsUInt
            ).mul(
                value: data.currencyTo.fiatPrice.bigDec
            ).mul(value: Double(100).bigDec) // this is because we want 2 decimals on currency
        ).toBigInt().formatStringCurrency()
        let currencyTo = ConfirmationViewModel.SwapViewModel.Currency(
            iconName: data.currencyTo.iconName,
            symbol: data.currencyTo.symbol,
            value: currencyFormatted(data.currencyTo, value: data.amountTo),
            usdValue: fiatToValue
        )
        let provider = ConfirmationViewModel.SwapViewModel.Provider(
            iconName: data.provider.iconName,
            name: data.provider.name,
            slippage: data.provider.slippage
        )
        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "🤷🏻‍♂️"
        let estimatedFee = ConfirmationViewModel.SwapViewModel.Fee(
            value: feeValueInToken,
            usdValue: feeValueInUSD
        )
        return .swap(
            .init(
                currencyFrom: currencyFrom,
                currencyTo: currencyTo,
                provider: provider,
                estimatedFee: estimatedFee
            )
        )
    }
    
    func contentViewModel(
        forSend data: ConfirmationWireframeContext.SendContext
    ) -> ConfirmationViewModel.Content {
        let fiatValue = (
            data.amount.toBigDec(
                decimals: data.currency.decimalsUInt
            ).mul(
                value: data.currency.fiatPrice.bigDec
            ).mul(value: Double(100).bigDec) // this is because we want 2 decimals on currency
        ).toBigInt().formatStringCurrency()
        let currency = ConfirmationViewModel.SendViewModel.Currency(
            iconName: data.currency.iconName,
            symbol: data.currency.symbol,
            value: currencyFormatted(data.currency, value: data.amount),
            usdValue: fiatValue
        )
        let destination = ConfirmationViewModel.SendViewModel.Destination(
            from: Formatters.Companion.shared.networkAddress.format(
                address: data.addressFrom, digits: 8, network: data.network
            ),
            to: Formatters.Companion.shared.networkAddress.format(
                address: data.addressTo, digits: 8, network: data.network
            )
        )
        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "🤷🏻‍♂️"
        let estimatedFee = ConfirmationViewModel.SendViewModel.Fee(
            value: feeValueInToken,
            usdValue: feeValueInUSD
        )
        return .send(
            .init(
                currency: currency,
                destination: destination,
                estimatedFee: estimatedFee
            )
        )
    }
    
    func contentViewModel(
        forSendNFT data: ConfirmationWireframeContext.SendNFTContext
    ) -> ConfirmationViewModel.Content {
        // TODO: Fix when supporting sending NFTs on different networks...
        let network = Network.Companion().ethereum()
        let destination = ConfirmationViewModel.SendNFTViewModel.Destination(
            from: Formatters.Companion.shared.networkAddress.format(
                address: data.addressFrom, digits: 8, network: network
            ),
            to: Formatters.Companion.shared.networkAddress.format(
                address: data.addressTo, digits: 8, network: network
            )
        )
        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "🤷🏻‍♂️"
        let estimatedFee = ConfirmationViewModel.SendNFTViewModel.Fee(
            value: feeValueInToken,
            usdValue: feeValueInUSD
        )
        return .sendNFT(
            .init(
                nftItem: data.nftItem,
                destination: destination,
                estimatedFee: estimatedFee
            )
        )
    }
    
    func contentViewModel(
        forCultCastVote data: ConfirmationWireframeContext.CultCastVoteContext
    ) -> ConfirmationViewModel.Content {
        .cultCastVote(
            .init(
                action: data.approve ? Localized("approve") : Localized("reject"),
                name: data.cultProposal.title
            )
        )
    }
    
    func contentViewModel(
        forApproveUniswap data: ConfirmationWireframeContext.ApproveUniswapContext
    ) -> ConfirmationViewModel.Content {
        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "🤷🏻‍♂️"
        let estimatedFee = ConfirmationViewModel.ApproveUniswapViewModel.Fee(
            value: feeValueInToken,
            usdValue: feeValueInUSD
        )
        return .approveUniswap(
            .init(
                iconName: data.currency.iconName,
                symbol: data.currency.symbol,
                fee: estimatedFee
            )
        )
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionInProgress() {
        let viewModel = ConfirmationViewModel(
            title: titleViewModel(),
            content: .inProgress(
                .init(
                    title: Localized("confirmation.tx.inProgress.\(context.type.localizedTag).title"),
                    message: Localized("confirmation.tx.inProgress.\(context.type.localizedTag).message")
                )
            )
        )
        view?.update(with: viewModel)
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionSuccess(_ response: TransactionResponse) {
        self.txHash = response.hash
        let viewModel = ConfirmationViewModel(
            title: titleViewModel(),
            content: .success(
                .init(
                    title: Localized("confirmation.tx.success.\(context.type.localizedTag).title"),
                    message: Localized("confirmation.tx.success.\(context.type.localizedTag).message"),
                    cta: Localized("confirmation.tx.success.\(context.type.localizedTag).cta"),
                    ctaSecondary: Localized("confirmation.tx.success.viewEtherScan")
                )
            )
        )
        view?.update(with: viewModel)
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionFailed(_ error: Error) {
        self.error = error
        let viewModel = ConfirmationViewModel(
            title: titleViewModel(),
            content: .failed(
                .init(
                    title: Localized("confirmation.tx.failed.\(context.type.localizedTag).title"),
                    error: error.localizedDescription,
                    cta: Localized("confirmation.tx.failed.\(context.type.localizedTag).cta"),
                    ctaSecondary: Localized("confirmation.tx.failed.report")
                )
            )
        )
        view?.update(with: viewModel)
    }
}

private extension DefaultConfirmationPresenter {
    
    func authenticateContext() -> AuthenticateWireframeContext {
        .init(
            title: Localized("authenticate.title.\(context.type.localizedTag)"),
            keyStoreItem: nil,
            handler: onAuthenticatedHandler()
        )
    }
    
    func onAuthenticatedHandler() -> (AuthenticateData?, KotlinError?) -> Void {
        {
            [weak self] data, error in
            if let data = data {
                self?.handleSuccessfulAuthentication(with: data.password, and: data.salt)
            } else {
                print(error ?? "No error but no data either")
            }
        }
    }
    
    func handleSuccessfulAuthentication(
        with password: String,
        and salt: String
    ) {
        showTransactionInProgress()
        broadcastTransaction(with: password, and: salt)
    }

    func broadcastTransaction(
        with password: String,
        and salt: String
    ) {
        txHash = nil
        error = nil
        switch context.type {
        case let .approveUniswap(context):
            context.onApproved((password: password, salt: salt))
            wireframe.dismiss()
        case let .swap(context):
            interactor.executeSwap(
                network: context.network,
                password: password,
                salt: salt,
                swapService: context.swapService,
                handler: { [weak self] result in
                    switch result {
                    case let .success(response):
                        self?.txHash = response.hash
                        self?.showTransactionSuccess(response)
                    case let .failure(error):
                        print("[ERROR]", error)
                        self?.showTransactionFailed(error)
                    }
                }
            )
        case let .send(data):
            interactor.send(
                addressTo: data.addressTo,
                network: data.network,
                currency: data.currency,
                amount: data.amount,
                networkFee: data.networkFee,
                password: password,
                salt: salt,
                handler: { [weak self] result in
                    switch result {
                    case let .success(response):
                        self?.showTransactionSuccess(response)
                    case let .failure(error):
                        self?.showTransactionFailed(error)
                    }
                }
            )
        case let .sendNFT(data):
            interactor.sendNFT(
                addressFrom: data.addressFrom,
                addressTo: data.addressTo,
                network: data.network,
                nft: data.nftItem,
                password: password,
                salt: salt,
                handler: { [weak self] result in
                    switch result {
                    case let .success(response):
                        self?.showTransactionSuccess(response)
                    case let .failure(error):
                        self?.showTransactionFailed(error)
                    }
                }
            )
        case let .cultCastVote(data):
            interactor.castVote(
                proposalId: data.cultProposal.id,
                support: data.approve,
                password: password,
                salt: salt,
                handler: { [weak self] result in
                    switch result {
                    case let .success(response):
                        self?.showTransactionSuccess(response)
                    case let .failure(error):
                        self?.showTransactionFailed(error)
                    }
                }
            )
        }
    }
}

private extension ConfirmationPresenter {
    
    func currencyFormatted(_ currency: Currency, value: BigInt) -> String {
        var currencyFormatted = value.formatString(
            type: .long(minDecimals: 10),
            decimals: currency.decimalsUInt
        )
        if currencyFormatted.nonDecimals.count > 10 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 4),
                decimals: currency.decimalsUInt
            )
        } else if currencyFormatted.nonDecimals.count > 6 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 5),
                decimals: currency.decimalsUInt
            )
        } else if currencyFormatted.nonDecimals.count > 3 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 7),
                decimals: currency.decimalsUInt
            )
        }
        return currencyFormatted + " \(currency.symbol)"
    }
}
