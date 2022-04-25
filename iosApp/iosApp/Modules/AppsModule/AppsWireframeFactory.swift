// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AppsWireframeFactory {

    func makeWireframe(_ parent: UITabBarController) -> AppsWireframe
}

final class DefaultAppsWireframeFactory {

    private let appsService: AppsService

    init(
        appsService: AppsService
    ) {
        self.appsService = appsService
    }
}

extension DefaultAppsWireframeFactory: AppsWireframeFactory {

    func makeWireframe(_ parent: UITabBarController) -> AppsWireframe {
        
        DefaultAppsWireframe(
            parent: parent,
            appsService: appsService
        )
    }
}
