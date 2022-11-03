// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol WebViewWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: WebViewWireframeContext
    ) -> WebViewWireframe
}

final class DefaultWebViewWireframeFactory {}

extension DefaultWebViewWireframeFactory: WebViewWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: WebViewWireframeContext
    ) -> WebViewWireframe {
        DefaultWebViewWireframe(
            parent,
            context: context
        )
    }
}

// MARK: Assembler

final class WebViewWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> WebViewWireframeFactory in
            DefaultWebViewWireframeFactory()
        }
    }
}
