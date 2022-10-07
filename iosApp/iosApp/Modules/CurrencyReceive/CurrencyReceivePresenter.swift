// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CurrencyReceivePresenterEvent {
    case dismiss
}

protocol CurrencyReceivePresenter {
    func present()
    func handle(_ event: CurrencyReceivePresenterEvent)
}

final class DefaultCurrencyReceivePresenter {
    private weak var view: CurrencyReceiveView?
    private let interactor: CurrencyReceiveInteractor
    private let wireframe: CurrencyReceiveWireframe
    private let context: CurrencyReceiveWireframeContext
    
    private var items = [CurrencyReceiveViewModel.Item]()

    init(
        view: CurrencyReceiveView,
        interactor: CurrencyReceiveInteractor,
        wireframe: CurrencyReceiveWireframe,
        context: CurrencyReceiveWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultCurrencyReceivePresenter: CurrencyReceivePresenter {

    func present() {
        view?.update(
            with: .init(
                title: Localized("currencyReceive.title.receive", context.currency.symbol.uppercased()),
                content: .loaded(
                    .init(
                        name: Localized("currencyReceive.qrcode.name"),
                        symbol: context.currency.symbol.uppercased(),
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

    func handle(_ event: CurrencyReceivePresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.dismiss()
        }
    }
}

private extension DefaultCurrencyReceivePresenter {
    var disclaimer: String {
        let arg = "\(context.network.name.capitalized) (\(context.currency.symbol.uppercased()))"
        return Localized("currencyReceive.disclaimer", arg)
    }
}
