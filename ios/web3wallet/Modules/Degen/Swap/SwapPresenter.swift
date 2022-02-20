// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum SwapPresenterEvent {

}

protocol SwapPresenter {

    func present()
    func handle(_ event: SwapPresenterEvent)
}

// MARK: - DefaultSwapPresenter

class DefaultSwapPresenter {

    private let interactor: SwapInteractor
    private let wireframe: SwapWireframe

    private weak var view: SwapView?

    init(
        view: SwapView,
        interactor: SwapInteractor,
        wireframe: SwapWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: SwapPresenter

extension DefaultSwapPresenter: SwapPresenter {

    func present() {
        view?.update(with: viewModel(interactor.dapp))
    }

    func handle(_ event: SwapPresenterEvent) {

    }
}

// MARK: - Event handling

private extension DefaultSwapPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultSwapPresenter {

    func viewModel(_ dapp: DApp) -> SwapViewModel {
        SwapViewModel.mock(dapp.name)
    }
}
