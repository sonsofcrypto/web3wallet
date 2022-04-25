// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum AMMsPresenterEvent {
    case didSelectDApp(idx: Int)
}

protocol AMMsPresenter {

    func present()
    func handle(_ event: AMMsPresenterEvent)
}

// MARK: - DefaultAMMsPresenter

final class DefaultAMMsPresenter {

    private let interactor: AMMsInteractor
    private let wireframe: AMMsWireframe

    private weak var view: AMMsView?

    init(
        view: AMMsView,
        interactor: AMMsInteractor,
        wireframe: AMMsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: AMMsPresenter

extension DefaultAMMsPresenter: AMMsPresenter {

    func present() {
        view?.update(with: viewModel(interactor.dapps()))
    }

    func handle(_ event: AMMsPresenterEvent) {
        switch event {
        case let .didSelectDApp(idx):
            handleDidSelectDapp(at: idx)
        }
    }
}

// MARK: - Event handling

private extension DefaultAMMsPresenter {

    func handleDidSelectDapp(at idx: Int) {
        wireframe.navigate(to: .dapp(interactor.dapps()[idx]))
    }
}

// MARK: - DefaultAMMsPresenter utilities

private extension DefaultAMMsPresenter {

    func viewModel(_ dapps: [DApp]) -> AMMsViewModel {
        .init(
            dapps: dapps.map {
                .init(
                    title: $0.name,
                    network: $0.network,
                    image: "dapp_icon_" + $0.name.lowercased()
                )
            }
        )
    }
}
