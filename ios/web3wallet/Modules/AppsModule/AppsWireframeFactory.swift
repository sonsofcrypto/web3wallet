// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AppsWireframeFactory {

    func makeWireframe() -> AppsWireframe
}

// MARK: - DefaultAppsWireframeFactory

class DefaultAppsWireframeFactory {

    private let service: AppsService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: AppsService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - AppsWireframeFactory

extension DefaultAppsWireframeFactory: AppsWireframeFactory {

    func makeWireframe() -> AppsWireframe {
        DefaultAppsWireframe(
            interactor: DefaultAppsInteractor(service),
            window: window
        )
    }
}