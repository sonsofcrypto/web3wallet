// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol NFTDetailWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe
}

final class DefaultNFTDetailWireframeFactory {
    private let nftSendWireframeFactory: NFTSendWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let nftsService: NFTsService
    private let walletService: WalletService
    private let networksService: NetworksService

    init(
        nftSendWireframeFactory: NFTSendWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        nftsService: NFTsService,
        walletService: WalletService,
        networksService: NetworksService
    ) {
        self.nftSendWireframeFactory = nftSendWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.nftsService = nftsService
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultNFTDetailWireframeFactory: NFTDetailWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: NFTDetailWireframeContext
    ) -> NFTDetailWireframe {
        DefaultNFTDetailWireframe(
            parent,
            context: context,
            nftSendWireframeFactory: nftSendWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            nftsService: nftsService,
            walletService: walletService,
            networksService: networksService
        )
    }
}

// MARK: - Assembler

final class NFTDetailWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NFTDetailWireframeFactory in
            DefaultNFTDetailWireframeFactory(
                nftSendWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                nftsService: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}

