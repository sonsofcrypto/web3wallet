// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum MnemonicsPresenterEvent {

}

protocol MnemonicsPresenter {

    func present()
    func handle(_ event: MnemonicsPresenterEvent)
}

// MARK: - DefaultMnemonicsPresenter

class DefaultMnemonicsPresenter {

    private var interactor: MnemonicsInteractor

    private weak var view: MnemonicsView?

    init(view: MnemonicsView, interactor: MnemonicsInteractor) {
        self.view = view
        self.interactor = interactor
    }
}

// MARK: - MnemonicsPresenter

extension DefaultMnemonicsPresenter: MnemonicsPresenter {

    func present() {

    }

    func handle(_ event: MnemonicsPresenterEvent) {

    }
}
