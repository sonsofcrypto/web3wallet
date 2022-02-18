// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe
}

// MARK: - DefaultDashboardWireframeFactory

class DefaultDashboardWireframeFactory {

    private let service: WalletsService

    init(
        _ service: WalletsService
    ) {
        self.service = service
    }
}

// MARK: - DashboardWireframeFactory

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe {
        DefaultDashboardWireframe(
            parent: parent,
            interactor: DefaultDashboardInteractor(service)
        )
    }
}