// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsWireframeFactory {

    func makeWireframe() -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

class DefaultSettingsWireframeFactory {

    private let service: SettingsService

    init(
        service: SettingsService
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