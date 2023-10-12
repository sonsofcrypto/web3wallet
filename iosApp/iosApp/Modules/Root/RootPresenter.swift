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
    private let signerStoreService: SignerStoreService

    init(
        view: RootView,
        wireframe: RootWireframe,
        signerStoreService: SignerStoreService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.signerStoreService = signerStoreService
    }
}

extension DefaultRootPresenter: RootPresenter {

    func present() {
        wireframe.navigate(
            to: signerStoreService.items().isEmpty ? .keyStore : .dashboard,
            animated: false
        )
    }
}
