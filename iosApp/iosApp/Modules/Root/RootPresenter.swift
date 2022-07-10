// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol RootPresenter {

    func present()
}

// MARK: - DefaultRootPresenter

final class DefaultRootPresenter {

    private weak var view: RootView?
    private let wireframe: RootWireframe
    private let keyStoreService: OldKeyStoreService

    init(
        view: RootView,
        wireframe: RootWireframe,
        keyStoreService: OldKeyStoreService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.keyStoreService = keyStoreService
    }
}

// MARK: RootPresenter

extension DefaultRootPresenter: RootPresenter {

    func present() {

        wireframe.navigate(
            to: keyStoreService.isEmpty() ? .keyStore : .dashboard,
            animated: false
        )
    }
}
