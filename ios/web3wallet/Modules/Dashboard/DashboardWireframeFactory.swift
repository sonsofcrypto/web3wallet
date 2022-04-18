// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe
}

// MARK: - DefaultDashboardWireframeFactory

class DefaultDashboardWireframeFactory {

    private let service: KeyStoreService
    private let accountWireframeFactory: AccountWireframeFactory
    private let onboardingService: OnboardingService

    init(
        _ service: KeyStoreService,
        accountWireframeFactory: AccountWireframeFactory,
        onboardingService: OnboardingService
    ) {
        self.service = service
        self.accountWireframeFactory = accountWireframeFactory
        self.onboardingService = onboardingService
    }
}

// MARK: - DashboardWireframeFactory

extension DefaultDashboardWireframeFactory: DashboardWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> DashboardWireframe {
        DefaultDashboardWireframe(
            parent: parent,
            interactor: DefaultDashboardInteractor(service),
            accountWireframeFactory: accountWireframeFactory,
            onboardingService: onboardingService
        )
    }
}