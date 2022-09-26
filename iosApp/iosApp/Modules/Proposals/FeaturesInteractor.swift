// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol FeaturesInteractor: AnyObject {
    func fetchAllFeatures(
        onCompletion: @escaping (Result<[ImprovementProposal], Error>) -> Void
    )
}

final class DefaultFeaturesInteractor {
    private let featureService: ImprovementProposalsService

    init(featureService: ImprovementProposalsService) {
        self.featureService = featureService
    }
}

extension DefaultFeaturesInteractor: FeaturesInteractor {

    func fetchAllFeatures(
        onCompletion: @escaping (Result<[ImprovementProposal], Error>) -> Void
    ) {
        featureService.fetchProposals(handler: onCompletion)
    }
}
