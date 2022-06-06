// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol CultProposalsInteractor: AnyObject {

    func closedProposals() -> [CultProposal]
    func pendingProposals() -> [CultProposal]
}

// MARK: - DefaultCultProposalsInteractor

class DefaultCultProposalsInteractor {

    private var cultService: CultService

    init(_ cultService: CultService) {
        self.cultService = cultService
    }
}

// MARK: - CultProposalsInteractor

extension DefaultCultProposalsInteractor: CultProposalsInteractor {

    func closedProposals() -> [CultProposal] {
        return cultService.closedProposals
    }

    func pendingProposals() -> [CultProposal] {
        return cultService.pendingProposals
    }
}
