// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol CultProposalsInteractor: AnyObject {

    var closedProposals: [CultProposal] { get }
    var pendingProposals: [CultProposal] { get }
}

final class DefaultCultProposalsInteractor {

    private let cultService: CultService

    init(_ cultService: CultService) {
        
        self.cultService = cultService
    }
}

extension DefaultCultProposalsInteractor: CultProposalsInteractor {

    var closedProposals: [CultProposal] {
        
        cultService.closedProposals
    }

    var pendingProposals: [CultProposal] {
        
        cultService.pendingProposals
    }
}
