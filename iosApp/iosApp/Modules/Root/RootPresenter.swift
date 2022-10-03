// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol RootPresenter {
    func present()
}

final class DefaultRootPresenter {
    private weak var view: RootView?
    private let wireframe: RootWireframe
    private let keyStoreService: KeyStoreService

    init(
        view: RootView,
        wireframe: RootWireframe,
        keyStoreService: KeyStoreService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.keyStoreService = keyStoreService
    }
}

extension DefaultRootPresenter: RootPresenter {

    func present() {
        wireframe.navigate(
            to: keyStoreService.items().isEmpty ? .keyStore : .dashboard,
            animated: false
        )
    }
}
