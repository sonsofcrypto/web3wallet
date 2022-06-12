// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalWireframeFactory {

    func makeWireframe(
        _ proposal: CultProposal,
        parent: UIViewController
    ) -> CultProposalWireframe
}

// MARK: - DefaultCultProposalWireframeFactory

class DefaultCultProposalWireframeFactory: CultProposalWireframeFactory {

    func makeWireframe(
        _ proposal: CultProposal,
        parent: UIViewController
    ) -> CultProposalWireframe {
        DefaultCultProposalWireframe(proposal: proposal, parent: parent)
    }
}