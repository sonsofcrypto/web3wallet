// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum WalletsPresenterEvent {

}

protocol WalletsPresenter {

    func present()
    func handle(_ event: WalletsPresenterEvent)
}

// MARK: - DefaultMnemonicsPresenter

class DefaultMnemonicsPresenter {

    private var interactor: WalletsInteractor

    private weak var view: WalletsView?

    init(view: WalletsView, interactor: WalletsInteractor) {
        self.view = view
        self.interactor = interactor
    }
}

// MARK: - MnemonicsPresenter

extension DefaultMnemonicsPresenter: WalletsPresenter {

    func present() {

    }

    func handle(_ event: WalletsPresenterEvent) {

    }
}
