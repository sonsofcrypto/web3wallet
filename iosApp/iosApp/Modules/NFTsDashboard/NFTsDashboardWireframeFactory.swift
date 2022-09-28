// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - NFTsDashboardWireframeFactory

protocol NFTsDashboardWireframeFactory {
    func make(_ parent: UIViewController?) -> NFTsDashboardWireframe
}

// MARK: - DefaultNFTsDashboardWireframeFactory

final class DefaultNFTsDashboardWireframeFactory {
    private let nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory
    private let nftDetailWireframeFactory: NFTDetailWireframeFactory
    private let nftsService: NFTsService
    private let networksService: NetworksService
    private let mailService: MailService

    init(
        nftsCollectionWireframeFactory: NFTsCollectionWireframeFactory,
        nftDetailWireframeFactory: NFTDetailWireframeFactory,
        nftsService: NFTsService,
        networksService: NetworksService,
        mailService: MailService
    ) {
        self.nftsCollectionWireframeFactory = nftsCollectionWireframeFactory
        self.nftDetailWireframeFactory = nftDetailWireframeFactory
        self.nftsService = nftsService
        self.networksService = networksService
        self.mailService = mailService
    }
}

extension DefaultNFTsDashboardWireframeFactory: NFTsDashboardWireframeFactory {

    func make(_ parent: UIViewController?) -> NFTsDashboardWireframe {
        DefaultNFTsDashboardWireframe(
            parent,
            nftsCollectionWireframeFactory: nftsCollectionWireframeFactory,
            nftDetailWireframeFactory: nftDetailWireframeFactory,
            nftsService: nftsService,
            networksService: networksService,
            mailService: mailService
        )
    }
}

// MARK: - Assembler

final class NFTsDashboardWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NFTsDashboardWireframeFactory in
            DefaultNFTsDashboardWireframeFactory(
                nftsCollectionWireframeFactory: resolver.resolve(),
                nftDetailWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve(),
                networksService: resolver.resolve(),
                mailService: resolver.resolve()
            )
        }
    }
}
