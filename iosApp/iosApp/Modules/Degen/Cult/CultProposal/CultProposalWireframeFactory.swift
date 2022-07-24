// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalWireframeFactory {

    func makeWireframe(
        parent: UIViewController,
        context: CultProposalWireframeContext
    ) -> CultProposalWireframe
}

final class DefaultCultProposalWireframeFactory: CultProposalWireframeFactory {

    func makeWireframe(
        parent: UIViewController,
        context: CultProposalWireframeContext
    ) -> CultProposalWireframe {
        
        DefaultCultProposalWireframe(
            parent: parent,
            context: context
        )
    }
}
