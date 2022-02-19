// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AppsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AppsWireframe
}

// MARK: - DefaultAppsWireframeFactory

class DefaultAppsWireframeFactory {

    private let service: AppsService

    init(
        _ service: AppsService
    ) {
        self.service = service
    }
}

// MARK: - AppsWireframeFactory

extension DefaultAppsWireframeFactory: AppsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AppsWireframe {
        DefaultAppsWireframe(
            parent: parent
            interactor: DefaultAppsInteractor(service)
        )
    }
}