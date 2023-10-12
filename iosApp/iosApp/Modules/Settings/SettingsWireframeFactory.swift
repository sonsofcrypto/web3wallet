// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol SettingsWireframeFactory {
    func make(
        _ parent: UIViewController?,
        screenId: SettingsScreenId
    ) -> SettingsWireframe
}

// MARK: - DefaultSettingsWireframeFactory

class DefaultSettingsWireframeFactory {
    private let webViewWireframeFactory: WebViewWireframeFactory
    private let improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory
    private let mailWireframeFactory: MailService
    private let settingsService: SettingsService
    private let signerStoreService: SignerStoreService

    init(
        webViewWireframeFactory: WebViewWireframeFactory,
        improvementProposalsWireframeFactory: ImprovementProposalsWireframeFactory,
        mailWireframeFactory: MailService,
        settingsService: SettingsService,
        signerStoreService: SignerStoreService
    ) {
        self.webViewWireframeFactory = webViewWireframeFactory
        self.improvementProposalsWireframeFactory = improvementProposalsWireframeFactory
        self.mailWireframeFactory = mailWireframeFactory
        self.settingsService = settingsService
        self.signerStoreService = signerStoreService
    }
}

// MARK: - TemplateWireframeFactory

extension DefaultSettingsWireframeFactory: SettingsWireframeFactory {
    
    func make(
        _ parent: UIViewController?,
        screenId: SettingsScreenId
    ) -> SettingsWireframe {
        DefaultSettingsWireframe(
            parent,
            screenId: screenId,
            webViewWireframeFactory: webViewWireframeFactory,
            improvementProposalsWireframeFactory: improvementProposalsWireframeFactory,
            mailWireframeFactory: mailWireframeFactory,
            settingsService: settingsService,
            signerStoreService: signerStoreService
        )
    }
}

// MARK: - Assembler

final class SettingsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> SettingsWireframeFactory in
            DefaultSettingsWireframeFactory(
                webViewWireframeFactory: resolver.resolve(),
                improvementProposalsWireframeFactory: resolver.resolve(),
                mailWireframeFactory: resolver.resolve(),
                settingsService: resolver.resolve(),
                signerStoreService: resolver.resolve()
            )
        }
    }
}
