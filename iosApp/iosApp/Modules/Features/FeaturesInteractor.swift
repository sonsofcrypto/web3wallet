// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol FeaturesInteractor: AnyObject {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    )
}

final class DefaultFeaturesInteractor {

    private let cultService: CultService

    init(_ cultService: CultService) {
        
        self.cultService = cultService
    }
}

extension DefaultFeaturesInteractor: FeaturesInteractor {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    ) {
        
        cultService.fetchProposals(onCompletion: onCompletion)
    }
}
