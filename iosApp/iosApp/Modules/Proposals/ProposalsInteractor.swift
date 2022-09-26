// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol ProposalsInteractor: AnyObject {
    func fetchAllFeatures(
        onCompletion: @escaping (Result<[ImprovementProposal], Error>) -> Void
    )
}

final class DefaultProposalsInteractor {
    private let improvementProposalsService: ImprovementProposalsService

    init(improvementProposalsService: ImprovementProposalsService) {
        self.improvementProposalsService = improvementProposalsService
    }
}

extension DefaultProposalsInteractor: ProposalsInteractor {

    func fetchAllFeatures(
        onCompletion: @escaping (Result<[ImprovementProposal], Error>) -> Void
    ) {
        improvementProposalsService.fetchProposals(handler: onCompletion)
    }
}
