// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TemplateWireframeFactory {
    func make(_ parent: UIViewController?) -> TemplateWireframe
}

// MARK: - DefaultTemplateWireframeFactory

final class DefaultTemplateWireframeFactory {

    private let service: TemplateService

    init(_ service: TemplateService) {
        self.service = service
    }
}

// MARK: - TemplateWireframeFactory

extension DefaultTemplateWireframeFactory: TemplateWireframeFactory {

    func make(_ parent: UIViewController?) -> TemplateWireframe {
        DefaultTemplateWireframe(
            parent,
            // context:
            templateWireframeFactory: self,
            service: service
        )
    }
}

// MARK: - TemplateWireframeAssembler

final class DefaultTemplateWireframeAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> TemplateWireframeFactory in
            DefaultTemplateWireframeFactory(resolver.resolve())
        }
    }
}