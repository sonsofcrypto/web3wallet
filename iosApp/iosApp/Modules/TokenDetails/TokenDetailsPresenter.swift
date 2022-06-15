// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenDetailsPresenterEvent {

    case dismiss
    case share
}

protocol TokenDetailsPresenter {

    func present()
    func handle(_ event: TokenDetailsPresenterEvent)
}

final class DefaultTokenDetailsPresenter {

    private weak var view: TokenDetailsView?
    private let interactor: TokenDetailsInteractor
    private let wireframe: TokenDetailsWireframe
    private let context: TokenDetailsWireframeContext
    
    private var items = [TokenDetailsViewModel.Item]()

    init(
        view: TokenDetailsView,
        interactor: TokenDetailsInteractor,
        wireframe: TokenDetailsWireframe,
        context: TokenDetailsWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenDetailsPresenter: TokenDetailsPresenter {

    func present() {
        
        view?.update(
            with: .init(
                title: Localized("tokenDetails.title.receive", arg: context.web3Token.symbol),
                content: .loaded(
                    .init(
                        name: Localized("tokenDetails.qrcode.name"),
                        symbol: context.web3Token.symbol,
                        address: context.web3Token.address,
                        disclaimer: disclaimer
                    )
                )
            )
        )
    }

    func handle(_ event: TokenDetailsPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.dismiss()

        case .share:
            
            break
        }
    }
}

private extension DefaultTokenDetailsPresenter {
    
    var disclaimer: String {
        
        let arg = "\(context.web3Token.network.name.capitalized) (\(context.web3Token.symbol))"
        return Localized("tokenDetails.disclaimer", arg: arg)
    }
}
