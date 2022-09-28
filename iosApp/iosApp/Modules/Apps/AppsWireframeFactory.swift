// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - AppsWireframeFactory

protocol AppsWireframeFactory {
    func make(_ parent: UIViewController?) -> AppsWireframe
}

// MARK: - DefaultAppsWireframeFactory

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

    func make(_ parent: UIViewController?) -> AppsWireframe {
        DefaultAppsWireframe(
            parent,
            chatWireframeFactory: chatWireframeFactory,
            appsService: appsService
        )
    }
}

// MARK: - Assembler

final class AppsWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> AppsWireframeFactory in
            DefaultAppsWireframeFactory(
                chatWireframeFactory: resolver.resolve(),
                appsService: resolver.resolve()
            )
        }
    }
}

