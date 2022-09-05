// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

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
        
        let viewModel = makeViewModel()
        view?.update(with: viewModel)
    }

    func handle(_ event: ConfirmationPresenterEvent) {

        switch event {
            
        case .confirm:
            switch context.type {
            case .send, .sendNFT, .cultCastVote, .approveUniswap, .swap:
                wireframe.navigate(to: .authenticate(makeAuthenticateContext()))
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
    
    func makeViewModel() -> ConfirmationViewModel {
        
        let content: ConfirmationViewModel.Content
        
        switch context.type {
        case let .swap(swapData):
            content = makeViewModelContent(forSwap: swapData)
        case let .send(sendData):
            content = makeViewModelContent(forSend: sendData)
        case let .sendNFT(sendNFTData):
            content = makeViewModelContent(forSendNFT: sendNFTData)
        case let .cultCastVote(cultCastVoteData):
            content = makeViewModelContent(forCultCastVote: cultCastVoteData)
        case let .approveUniswap(approveUniswapData):
            content = makeViewModelContent(forApproveUniswap: approveUniswapData)
        }
        
        return .init(title: makeTitle(), content: content)
    }
    
    func makeTitle() -> String {
        
        Localized("confirmation.\(context.type.localizedTag).title")
    }
    
    func makeViewModelContent(
        forSwap data: ConfirmationWireframeContext.SwapContext
    ) -> ConfirmationViewModel.Content {
        
        let usdTokenFromValue = (
            data.tokenFrom.value.toBigDec(
                decimals: data.tokenFrom.token.decimals
            ).mul(
                value: data.tokenFrom.token.usdPrice.bigDec
            ).mul(
                value: Double(100).bigDec // this is because we want 2 decimals on currency
            )
        ).toBigInt().formatStringCurrency()
        let tokenFrom = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenFrom.iconName,
            symbol: data.tokenFrom.token.symbol,
            value: data.tokenFrom.currencyFormatted + " \(data.tokenFrom.token.symbol)",
            usdValue: usdTokenFromValue
        )

        let usdTokenToValue = (
            data.tokenTo.value.toBigDec(
                decimals: data.tokenTo.token.decimals
            ).mul(
                value: data.tokenTo.token.usdPrice.bigDec
            ).mul(
                value: Double(100).bigDec // this is because we want 2 decimals on currency
            )
        ).toBigInt().formatStringCurrency()
        let tokenTo = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenTo.iconName,
            symbol: data.tokenTo.token.symbol,
            value: data.tokenTo.currencyFormatted + " \(data.tokenTo.token.symbol)",
            usdValue: usdTokenToValue
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
                tokenFrom: tokenFrom,
                tokenTo: tokenTo,
                provider: provider,
                estimatedFee: estimatedFee
            )
        )
    }
    
    func makeViewModelContent(
        forSend data: ConfirmationWireframeContext.SendContext
    ) -> ConfirmationViewModel.Content {
        
        let usdToken = data.token.token.usdPrice(for: data.token.value).formatStringCurrency()
        let token = ConfirmationViewModel.SendViewModel.Token(
            iconName: data.token.iconName,
            symbol: data.token.token.symbol,
            value: data.token.currencyFormatted + " \(data.token.token.symbol)",
            usdValue: usdToken
        )
        
        let destination = ConfirmationViewModel.SendViewModel.Destination(
            from: Formatter.address.string(
                data.destination.from,
                for: data.token.token.network.toNetwork()
            ),
            to: Formatter.address.string(
                data.destination.to,
                for: data.token.token.network.toNetwork()
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
                token: token,
                destination: destination,
                estimatedFee: estimatedFee
            )
        )
    }
    
    func makeViewModelContent(
        forSendNFT data: ConfirmationWireframeContext.SendNFTContext
    ) -> ConfirmationViewModel.Content {
        
        // TODO: Fix when supporting sending NFTs on different networks...
        let network = Network.Companion().ethereum()
        let destination = ConfirmationViewModel.SendNFTViewModel.Destination(
            from: Formatter.address.string(
                data.destination.from,
                for:network
            ),
            to: Formatter.address.string(
                data.destination.to,
                for: network
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
    
    func makeViewModelContent(
        forCultCastVote data: ConfirmationWireframeContext.CultCastVoteContext
    ) -> ConfirmationViewModel.Content {
        
        .cultCastVote(
            .init(
                action: data.approve ? Localized("approve") : Localized("reject"),
                name: data.cultProposal.title
            )
        )
    }
    
    func makeViewModelContent(
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
                iconName: data.iconName,
                symbol: data.token.symbol,
                fee: estimatedFee
            )
        )
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionInProgress() {
        
        let viewModel = ConfirmationViewModel(
            title: makeTitle(),
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
            title: makeTitle(),
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
            title: makeTitle(),
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
    
    func makeAuthenticateContext() -> AuthenticateContext {

        .init(
            title: Localized("authenticate.title.\(context.type.localizedTag)"),
            keyStoreItem: nil,
            handler: makeOnAuthenticatedHandler()
        )
    }
    
    func makeOnAuthenticatedHandler() -> (Result<(String, String), Error>) -> Void {
        
        {
            [weak self] result in
            
            guard let self = self else { return }
            switch result {
            case let .success((password, salt)):
                self.handleSuccessfulAuthentication(with: password, and: salt)
            case let .failure(error):
                print("error: \(error)")
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
                network: context.tokenFrom.token.network.toNetwork(),
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
                tokenFrom: data.token.token,
                toAddress: data.destination.to,
                amount: data.token.value,
                fee: data.estimatedFee,
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
                from: data.destination.from,
                to: data.destination.to,
                nft: data.nftItem,
                password: password,
                salt: salt,
                network: Network.Companion().ethereum(),
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

private extension ConfirmationWireframeContext.CurrencyData {
    
    var currencyFormatted: String {
        
        var currencyFormatted = value.formatString(
            type: .long(minDecimals: 10),
            decimals: token.decimals
        )
        if currencyFormatted.nonDecimals.count > 10 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 4),
                decimals: token.decimals
            )
        } else if currencyFormatted.nonDecimals.count > 6 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 5),
                decimals: token.decimals
            )
        } else if currencyFormatted.nonDecimals.count > 3 {
            currencyFormatted = value.formatString(
                type: .long(minDecimals: 7),
                decimals: token.decimals
            )
        }
        return currencyFormatted
    }
}
