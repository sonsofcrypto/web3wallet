// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DashboardWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .instance) { resolver -> DashboardWireframeFactory in
            
            DefaultDashboardWireframeFactory(
                accountWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                mnemonicConfirmationWireframeFactory: resolver.resolve(),
                tokenPickerWireframeFactory: resolver.resolve(),
                tokenSendWireframeFactory: resolver.resolve(),
                tokenSwapWireframeFactory: resolver.resolve(),
                nftDetailWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
                onboardingService: resolver.resolve(),
                deepLinkHandler: resolver.resolve(),
                web3Service: resolver.resolve(),
                priceHistoryService: resolver.resolve(),
                nftsService: resolver.resolve()
            )
        }
    }
}
