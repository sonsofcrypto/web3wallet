// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TemplateWireframeFactory {

    func makeWireframe() -> AccountWireframe
}

// MARK: - DefaultTemplateWireframeFactory

class DefaultTemplateWireframeFactory {

    private let service: TemplateService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: TemplateService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - TemplateWireframeFactory

extension DefaultTemplateWireframeFactory: AccountWireframeFactory {

    func makeWireframe() -> AccountWireframe {
        DefaultTemplateWireframe(
            interactor: DefaultTemplateInteractor(service),
            window: window
        )
    }
}