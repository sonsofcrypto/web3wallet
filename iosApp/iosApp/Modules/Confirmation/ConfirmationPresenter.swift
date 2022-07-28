// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum ConfirmationPresenterEvent {

    case confirm
    case dismiss
}

protocol ConfirmationPresenter {

    func present()
    func handle(_ event: ConfirmationPresenterEvent)
}

final class DefaultConfirmationPresenter {

    private weak var view: ConfirmationView?
    private let wireframe: ConfirmationWireframe
    private let context: ConfirmationWireframeContext
    
    init(
        view: ConfirmationView,
        wireframe: ConfirmationWireframe,
        context: ConfirmationWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultConfirmationPresenter: ConfirmationPresenter {

    func present() {
        
        let viewModel = makeViewModel()
        view?.update(with: viewModel)
    }

    func handle(_ event: ConfirmationPresenterEvent) {

        switch event {
            
        case .confirm:
            
            wireframe.navigate(
                to: .authenticate(makeAuthenticateContext())
            )
            
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

        }
        
        return .init(title: makeTitle(), content: content)
    }
    
    func makeTitle() -> String {
        
        switch context.type {
            
        case .swap:
            
            return Localized("confirmation.swap.title")
            
        case .send:
            
            return Localized("confirmation.send.title")
        }
    }
    
    func makeViewModelContent(
        forSwap data: ConfirmationWireframeContext.SwapContext
    ) -> ConfirmationViewModel.Content {
        
        let usdTokenFromValue = (
            data.tokenFrom.value * data.tokenFrom.token.usdPrice
        ).formatCurrency() ?? ""
        let tokenFrom = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenFrom.iconName,
            symbol: data.tokenFrom.token.symbol,
            value: data.tokenFrom.value.toString(decimals: data.tokenFrom.token.decimals),
            usdValue: usdTokenFromValue
        )

        let usdTokenToValue = (
            data.tokenTo.value * data.tokenTo.token.usdPrice
        ).formatCurrency() ?? ""
        let tokenTo = ConfirmationViewModel.SwapViewModel.Token(
            iconName: data.tokenTo.iconName,
            symbol: data.tokenTo.token.symbol,
            value: data.tokenTo.value.toString(decimals: data.tokenTo.token.decimals),
            usdValue: usdTokenToValue
        )
        
        let provider = ConfirmationViewModel.SwapViewModel.Provider(
            iconName: data.provider.iconName,
            name: data.provider.name,
            slippage: data.provider.slippage
        )
        
        let estimatedFeeUSD = (
            data.estimatedFee * data.tokenFrom.token.usdPrice
        ).formatCurrency() ?? ""
        let estimatedFee = ConfirmationViewModel.SwapViewModel.Fee(
            value: data.estimatedFee.toString(decimals: data.tokenFrom.token.decimals),
            usdValue: estimatedFeeUSD
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
        
        let usdToken = (
            data.token.value * data.token.token.usdPrice
        ).formatCurrency() ?? ""
        let token = ConfirmationViewModel.SendViewModel.Token(
            iconName: data.token.iconName,
            symbol: data.token.token.symbol,
            value: data.token.value.toString(decimals: data.token.token.decimals),
            usdValue: usdToken
        )
        
        let destination = ConfirmationViewModel.SendViewModel.Destination(
            from: data.destination.from,
            to: data.destination.to
        )

        let estimatedFeeUSD = (
            data.estimatedFee * data.token.token.usdPrice
        ).formatCurrency() ?? ""
        let estimatedFee = ConfirmationViewModel.SendViewModel.Fee(
            value: data.estimatedFee.toString(decimals: data.token.token.decimals),
            usdValue: estimatedFeeUSD
        )

        return .send(
            .init(
                token: token,
                destination: destination,
                estimatedFee: estimatedFee
            )
        )
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
        
        switch context.type {
            
        case .swap:
            
            print("Do swap!")
            print("Authenticated with: \(password) and \(salt)")

        case .send:
            
            print("Do send!")
            print("Authenticated with: \(password) and \(salt)")
        }
    }

}
