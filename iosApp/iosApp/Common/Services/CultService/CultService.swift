// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol CultService {
    var pendingProposals: [CultProposal] { get }
    var closedProposals: [CultProposal] { get }
}

// MARK: - DefaultCultService

final class DefaultCultService {

    var pendingProposals: [CultProposal] = CultProposal.pendingProposals()
    var closedProposals: [CultProposal] = CultProposal.closedMocks()
}

// MARK: - CultService

extension DefaultCultService: CultService {

}
