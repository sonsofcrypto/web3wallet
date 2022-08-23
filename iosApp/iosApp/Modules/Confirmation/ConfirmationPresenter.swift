// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum ConfirmationPresenterEvent {

    case confirm
    case txSuccessCTATapped
    case txFailedCTATapped
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
                
            case .send, .sendNFT:
                
                showTransactionInProgress()
                broadcastTransaction(with: "password", and: "salt")
//                wireframe.navigate(
//                    to: .authenticate(makeAuthenticateContext())
//                )
                                
            case .swap:
                
                wireframe.navigate(to: .underConstruction)
            }
            
        case .txSuccessCTATapped:
            
            wireframe.navigate(to: .account)

        case .txFailedCTATapped:
            
            wireframe.dismiss()

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

        }
        
        return .init(title: makeTitle(), content: content)
    }
    
    func makeTitle() -> String {
        
        switch context.type {
            
        case .swap:
            
            return Localized("confirmation.swap.title")
            
        case .send:
            
            return Localized("confirmation.send.title")

        case .sendNFT:
            
            return Localized("confirmation.sendNFT.title")
        }
    }
    
    func makeViewModelContent(
        forSwap data: ConfirmationWireframeContext.SwapContext
    ) -> ConfirmationViewModel.Content {
        
        let usdTokenFromValue = (
            data.tokenFrom.value * data.tokenFrom.token.usdPrice
        ).formatStringCurrency()
        let tokenFrom = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenFrom.iconName,
            symbol: data.tokenFrom.token.symbol,
            value: data.tokenFrom.value.formatString(decimals: data.tokenFrom.token.decimals),
            usdValue: usdTokenFromValue
        )

        let usdTokenToValue = (
            data.tokenTo.value * data.tokenTo.token.usdPrice
        ).formatStringCurrency()
        let tokenTo = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenTo.iconName,
            symbol: data.tokenTo.token.symbol,
            value: data.tokenTo.value.formatString(decimals: data.tokenFrom.token.decimals),
            usdValue: usdTokenToValue
        )
        
        let provider = ConfirmationViewModel.SwapViewModel.Provider(
            iconName: data.provider.iconName,
            name: data.provider.name,
            slippage: data.provider.slippage
        )
        
        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "value usd"
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
        
        let usdToken = data.token.token.usdBalance.formatStringCurrency()
        let token = ConfirmationViewModel.SendViewModel.Token(
            iconName: data.token.iconName,
            symbol: data.token.token.symbol,
            value: data.token.value.formatString(decimals: data.token.token.decimals),
            usdValue: usdToken
        )
        
        let destination = ConfirmationViewModel.SendViewModel.Destination(
            from: data.destination.from,
            to: data.destination.to
        )

        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "value usd"
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
        
        let destination = ConfirmationViewModel.SendNFTViewModel.Destination(
            from: data.destination.from,
            to: data.destination.to
        )

        // TODO: @Annon to show price here
        let feeValueInToken = "value token"
        let feeValueInUSD = "value usd"
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
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionInProgress() {
        
        let viewModel = ConfirmationViewModel(
            title: makeTitle(),
            content: .inProgress(
                .init(
                    title: makeTransactionInProgressTitle(),
                    message: makeTransactionInProgressMessage()
                )
            )
        )
        view?.update(with: viewModel)
    }
    
    func makeTransactionInProgressTitle() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.inProgress.send.title")
        case .sendNFT:
            return Localized("confirmation.tx.inProgress.sendNFT.title")
        case .swap:
            return Localized("confirmation.tx.inProgress.swap.title")
        }
    }
    
    func makeTransactionInProgressMessage() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.inProgress.send.message")
        case .sendNFT:
            return Localized("confirmation.tx.inProgress.sendNFT.message")
        case .swap:
            return Localized("confirmation.tx.inProgress.swap.message")
        }
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionSuccess() {
        
        let viewModel = ConfirmationViewModel(
            title: makeTitle(),
            content: .success(
                .init(
                    title: makeTransactionSuccessTitle(),
                    message: makeTransactionSuccessMessage(),
                    cta: makeTransactionSucessCTA()
                )
            )
        )
        view?.update(with: viewModel)
    }
    
    func makeTransactionSuccessTitle() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.success.send.title")
        case .sendNFT:
            return Localized("confirmation.tx.success.sendNFT.title")
        case .swap:
            return Localized("confirmation.tx.success.swap.title")
        }
    }
    
    func makeTransactionSuccessMessage() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.success.send.message")
        case .sendNFT:
            return Localized("confirmation.tx.success.sendNFT.message")
        case .swap:
            return Localized("confirmation.tx.success.swap.message")
        }
    }
    
    func makeTransactionSucessCTA() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.success.send.cta")
        case .sendNFT:
            return Localized("confirmation.tx.success.sendNFT.cta")
        case .swap:
            return Localized("confirmation.tx.success.swap.cta")
        }
    }
}

private extension DefaultConfirmationPresenter {
    
    func showTransactionFailed(_ error: Error? = nil) {
        
        let viewModel = ConfirmationViewModel(
            title: makeTitle(),
            content: .failed(
                .init(
                    title: makeTransactionFailedTitle(),
                    message: makeTransactionFailedMessage(),
                    cta: makeTransactionFailedCTA()
                )
            )
        )
        view?.update(with: viewModel)
    }
    
    func makeTransactionFailedTitle() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.failed.send.title")
        case .sendNFT:
            return Localized("confirmation.tx.failed.sendNFT.title")
        case .swap:
            return Localized("confirmation.tx.failed.swap.title")
        }
    }
    
    func makeTransactionFailedMessage() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.failed.send.message")
        case .sendNFT:
            return Localized("confirmation.tx.failed.sendNFT.message")
        case .swap:
            return Localized("confirmation.tx.failed.swap.message")
        }
    }
    
    func makeTransactionFailedCTA() -> String {
        
        switch context.type {
        case .send:
            return Localized("confirmation.tx.failed.send.cta")
        case .sendNFT:
            return Localized("confirmation.tx.failed.sendNFT.cta")
        case .swap:
            return Localized("confirmation.tx.failed.swap.cta")
        }
    }
}

private extension DefaultConfirmationPresenter {
    
    func makeAuthenticateContext() -> AuthenticateContext {

        .init(
            title: makeAuthenticateTitle(),
            keyStoreItem: nil,
            handler: makeOnAuthenticatedHandler()
        )
    }
    
    func makeAuthenticateTitle() -> String {
        
        switch context.type {
            
        case .swap:
            
            return Localized("authenticate.title.swap")
                    
        case .send:
            
            return Localized("authenticate.title.send")
            
        case .sendNFT:
            
            return Localized("authenticate.title.sendNFT")

        }
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
       
        switch context.type {
        case .swap:
            print("Do swap!")

        case let .send(data):
            interactor.send(
                tokenFrom: data.token.token,
                toAddress: data.destination.to,
                balance: data.token.value,
                fee: data.estimatedFee,
                password: password,
                salt: salt,
                handler: { [weak self] result in
                    switch result {
                    case .success:
                        self?.showTransactionSuccess()
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
                    case .success:
                        self?.showTransactionSuccess()
                    case let .failure(error):
                        self?.showTransactionFailed(error)
                    }
                }
            )
        }
    }
}
