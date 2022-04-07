//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DegenWireframe
}

final class DefaultDegenWireframeFactory {

    private let service: DegenService
    private let ammsWireframeFactory: AMMsWireframeFactory

    private weak var window: UIWindow?

    init(
        service: DegenService,
        ammsWireframeFactory: AMMsWireframeFactory
    ) {
        self.service = service
        self.ammsWireframeFactory = ammsWireframeFactory
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DegenWireframe {
        DefaultDegenWireframe(
            parent: parent,
            interactor: DefaultDegenInteractor(service),
            ammsWireframeFactory: ammsWireframeFactory
        )
    }
}
