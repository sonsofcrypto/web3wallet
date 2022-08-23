// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol CultProposalsInteractor: AnyObject {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    )
}

final class DefaultCultProposalsInteractor {

    private let cultService: CultService

    init(_ cultService: CultService) {
        self.cultService = cultService
    }
}

extension DefaultCultProposalsInteractor: CultProposalsInteractor {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    ) {
        cultService.fetchProposals(handler: onCompletion)
    }
}
