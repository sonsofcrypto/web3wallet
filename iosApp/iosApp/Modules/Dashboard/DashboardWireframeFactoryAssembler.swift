// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DashboardWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> DashboardWireframeFactory in
            
            DefaultDashboardWireframeFactory(
                keyStoreService: resolver.resolve(),
                accountWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                mnemonicConfirmationWireframeFactory: resolver.resolve(),
                onboardingService: resolver.resolve(),
                web3Service: resolver.resolve(),
                priceHistoryService: resolver.resolve()
            )
        }
    }
}
