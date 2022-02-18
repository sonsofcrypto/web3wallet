// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory {

    func makeWireframe() -> DashboardWireframe
}

// MARK: - DefaultDashboardWireframeFactory

class DefaultDashboardWireframeFactory {

    private let service: WalletsService

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        service: WalletsService
    ) {
        self.window = window
        self.service = service
    }
}

// MARK: - DashboardWireframeFactory

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe() -> DashboardWireframe {
        DefaultDashboardWireframe(
            interactor: DefaultDashboardInteractor(service),
            window: window
        )
    }
}