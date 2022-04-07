//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe
}

final class DefaultSwapWireframeFactory {

    private let service: DegenService

    init(
        service: DegenService
    ) {
        self.service = service
    }
}

extension DefaultSwapWireframeFactory: SwapWireframeFactory {

    func makeWireframe(_ parent: UIViewController, dapp: DApp) -> SwapWireframe {
        DefaultSwapWireframe(
            parent: parent,
            interactor: DefaultSwapInteractor(dapp, service: service)
        )
    }
}
