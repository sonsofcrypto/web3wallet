// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum CultProposalsWireframeDestination {
    case proposal(proposal: CultProposal)
}

protocol CultProposalsWireframe {
    func present()
    func navigate(to destination: CultProposalsWireframeDestination)
}

// MARK: - DefaultCultProposalsWireframe

class DefaultCultProposalsWireframe {

    private let interactor: CultProposalsInteractor
    private let factory: CultProposalWireframeFactory

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    init(
        interactor: CultProposalsInteractor,
        parent: UIViewController,
        factory: CultProposalWireframeFactory
    ) {
        self.interactor = interactor
        self.parent = parent
        self.factory = factory
    }
}

// MARK: - CultProposalsWireframe

extension DefaultCultProposalsWireframe: CultProposalsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalsWireframeDestination) {
        print("navigate to \(destination)")
        switch destination {
        case let .proposal(proposal):
            guard let vc = vc ?? parent else {
                return
            }
            factory.makeWireframe(proposal, parent: vc).present()
        }
    }
}

extension DefaultCultProposalsWireframe {

    private func wireUp() -> UIViewController {
        let vc: CultProposalsViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultCultProposalsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
