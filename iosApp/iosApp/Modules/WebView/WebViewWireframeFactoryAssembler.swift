// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class WebViewWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> WebViewWireframeFactory in
            DefaultWebViewWireframeFactory()
        }
    }
}
