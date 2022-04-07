//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol AppsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AppsWireframe
}

final class DefaultAppsWireframeFactory {

    private let service: AppsService

    init(
        service: AppsService
    ) {
        self.service = service
    }
}

extension DefaultAppsWireframeFactory: AppsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AppsWireframe {
        DefaultAppsWireframe(
            parent: parent,
            interactor: DefaultAppsInteractor(service)
        )
    }
}
