// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TokenReceivePresenterEvent {
    case dismiss
}

protocol TokenReceivePresenter {
    func present()
    func handle(_ event: TokenReceivePresenterEvent)
}

final class DefaultTokenReceivePresenter {
    private weak var view: TokenReceiveView?
    private let interactor: TokenReceiveInteractor
    private let wireframe: TokenReceiveWireframe
    private let context: TokenReceiveWireframeContext
    
    private var items = [TokenReceiveViewModel.Item]()

    init(
        view: TokenReceiveView,
        interactor: TokenReceiveInteractor,
        wireframe: TokenReceiveWireframe,
        context: TokenReceiveWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenReceivePresenter: TokenReceivePresenter {

    func present() {
        view?.update(
            with: .init(
                title: Localized("tokenReceive.title.receive", arg: context.currency.symbol),
                content: .loaded(
                    .init(
                        name: Localized("tokenReceive.qrcode.name"),
                        symbol: context.currency.symbol,
                        address: interactor.receivingAddress(
                            network: context.network,
                            currency: context.currency
                        ),
                        disclaimer: disclaimer
                    )
                )
            )
        )
    }

    func handle(_ event: TokenReceivePresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenReceivePresenter {
    var disclaimer: String {
        let arg = "\(context.network.name.capitalized) (\(context.currency.symbol))"
        return Localized("tokenReceive.disclaimer", arg: arg)
    }
}
