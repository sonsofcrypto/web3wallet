// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCultProposalWireframe {
    private weak var parent: UIViewController?
    private let context: CultProposalWireframeContext
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: CultProposalWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultCultProposalWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalWireframeDestination) {
        if destination is CultProposalWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCultProposalWireframe {

    func wireUp() -> UIViewController {
        let vc: CultProposalViewController = UIStoryboard(.cultProposal).instantiate()
        let presenter = DefaultCultProposalPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
