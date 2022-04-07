//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

class DefaultSettingsWireframeFactory {

    private let service: SettingsService

    init(
        _ service: SettingsService
    ) {
        self.service = service
    }
}

// MARK: - SettingsWireframeFactory

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent: parent,
            interactor: DefaultSettingsInteractor(service)
        )
    }
}
