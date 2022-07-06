// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenSendPresenterEvent {

    case dismiss
    case share
    case addCoins(onCompletion: (Double) -> Void)
}

protocol TokenSendPresenter {

    func present()
    func handle(_ event: TokenSendPresenterEvent)
}

final class DefaultTokenSendPresenter {

    private weak var view: TokenSendView?
    private let interactor: TokenSendInteractor
    private let wireframe: TokenSendWireframe
    private let context: TokenSendWireframeContext
    
    private var items = [TokenSendViewModel.Item]()

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
    }
}

extension DefaultTokenSendPresenter: TokenSendPresenter {

    func present() {
        
        view?.update(
            with: .init(
                title: Localized("TokenSend.title.receive", arg: context.web3Token.symbol),
                content: .loaded(
                    .init(
                        name: Localized("TokenSend.qrcode.name"),
                        symbol: context.web3Token.symbol,
                        address: context.web3Token.address,
                        disclaimer: disclaimer
                    )
                )
            )
        )
    }

    func handle(_ event: TokenSendPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()

        case .share:
            
            break
            
        case let .addCoins(onCompletion):
            
            let localStorage: Web3ServiceLocalStorage = ServiceDirectory.assembler.resolve()
            var allTokens = localStorage.readAllTokens()

            guard let token = allTokens.first(
                where: {
                    context.web3Token.equalTo(network: $0.network.name, symbol: $0.symbol)
                }
            ) else { return }

            allTokens.removeAll { $0.equalTo(network: token.network.name, symbol: token.symbol) }
            
            let coinsToAdd = 1000/token.usdPrice

            let updatedToken = Web3Token(
                symbol: token.symbol,
                name: token.name,
                address: token.address,
                decimals: token.decimals,
                type: token.type,
                network: token.network,
                balance: token.balance + coinsToAdd,
                showInWallet: true,
                usdPrice: token.usdPrice
            )
            
            allTokens.append(updatedToken)
            
            localStorage.storeAllTokens(with: allTokens)
            
            onCompletion(coinsToAdd)
        }
    }
}

private extension DefaultTokenSendPresenter {
    
    var disclaimer: String {
        
        let arg = "\(context.web3Token.network.name.capitalized) (\(context.web3Token.symbol))"
        return Localized("TokenSend.disclaimer", arg: arg)
    }
}
