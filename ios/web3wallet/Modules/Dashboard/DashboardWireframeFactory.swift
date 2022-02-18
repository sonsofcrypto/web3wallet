// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory {

    func makeWireframe() -> DashboardWireframe
}

// MARK: - DefaultDashboardWireframeFactory

class DefaultDashboardWireframeFactory {

    private let service: TemplateSerivce

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: TemplateSerivce
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - DashboardWireframeFactory

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe() -> DashboardWireframe {
        DefaultTemplateWireframe(
            interactor: DefaultTemplateInteractor(service),
            window: window
        )
    }
}