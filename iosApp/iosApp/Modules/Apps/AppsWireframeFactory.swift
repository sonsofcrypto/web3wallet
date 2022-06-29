// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AppsWireframeFactory {

    func makeWireframe(_ presentingIn: UITabBarController) -> AppsWireframe
}

final class DefaultAppsWireframeFactory {

    private let chatWireframeFactory: ChatWireframeFactory
    private let appsService: AppsService

    init(
        chatWireframeFactory: ChatWireframeFactory,
        appsService: AppsService
    ) {
        self.chatWireframeFactory = chatWireframeFactory
        self.appsService = appsService
    }
}

extension DefaultAppsWireframeFactory: AppsWireframeFactory {

    func makeWireframe(_ presentingIn: UITabBarController) -> AppsWireframe {
        
        DefaultAppsWireframe(
            presentingIn: presentingIn,
            chatWireframeFactory: chatWireframeFactory,
            appsService: appsService
        )
    }
}
