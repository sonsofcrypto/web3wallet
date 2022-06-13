// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum CultProposalWireframeDestination {

}

protocol CultProposalWireframe {
    func present()
    func navigate(to destination: CultProposalWireframeDestination)
}

// MARK: - DefaultCultProposalWireframe

class DefaultCultProposalWireframe {

    private weak var parent: UIViewController?

    private let proposal: CultProposal

    init(
        proposal: CultProposal,
        parent: UIViewController
    ) {
        self.proposal = proposal
        self.parent = parent
    }
}

// MARK: - CultProposalWireframe

extension DefaultCultProposalWireframe: CultProposalWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalWireframeDestination) {

    }
}

extension DefaultCultProposalWireframe {

    private func wireUp() -> UIViewController {
        let vc: CultProposalViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultCultProposalPresenter(
            proposal: proposal,
            view: vc,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
