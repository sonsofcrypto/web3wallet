// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol CultProposalsInteractor: AnyObject {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    )
    var hasCultBalance: Bool { get }
}

final class DefaultCultProposalsInteractor {

    private let cultService: CultService
    private let walletSercie: WalletService

    init(
        _ cultService: CultService,
        walletService: WalletService
    ) {
        self.cultService = cultService
        self.walletSercie = walletService
    }
}

extension DefaultCultProposalsInteractor: CultProposalsInteractor {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    ) {
        cultService.fetchProposals(handler: onCompletion)
    }
    
    var hasCultBalance: Bool {
        // TODO: Review this when supporting CULT on other networks
        let network = Network.Companion().ethereum()
        let currency = Currency.Companion().cult()
        let balance = walletSercie.balance(network: network, currency: currency)
        guard balance > .zero else { return false }
        return true
    }
}
