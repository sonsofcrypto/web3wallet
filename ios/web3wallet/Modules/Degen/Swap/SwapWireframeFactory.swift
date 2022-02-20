// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe
}

// MARK: - DefaultSwapWireframeFactory

class DefaultSwapWireframeFactory {

    private let service: DegenService

    init(
        service: DegenService
    ) {
        self.service = service
    }
}

// MARK: - SwapWireframeFactory

extension DefaultSwapWireframeFactory: SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe {
        DefaultSwapWireframe(
            parent: parent,
            interactor: DefaultSwapInteractor(dapp, service: service)
        )
    }
}