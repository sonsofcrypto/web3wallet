//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> SettingsWireframe
}

final class DefaultSettingsWireframeFactory {

    private let service: SettingsService

    init(
        service: SettingsService
    ) {
        self.service = service
    }
}

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent: parent,
            interactor: DefaultSettingsInteractor(service)
        )
    }
}
