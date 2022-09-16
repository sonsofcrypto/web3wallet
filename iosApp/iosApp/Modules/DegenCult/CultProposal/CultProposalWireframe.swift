// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct CultProposalWireframeContext {
    
    let proposal: CultProposal
    let proposals: [CultProposal]
}

enum CultProposalWireframeDestination {

    case dismiss
}

protocol CultProposalWireframe {
    func present()
    func navigate(to destination: CultProposalWireframeDestination)
}

final class DefaultCultProposalWireframe {

    private weak var parent: UIViewController!
    private let context: CultProposalWireframeContext

    init(
        parent: UIViewController,
        context: CultProposalWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultCultProposalWireframe: CultProposalWireframe {

    func present() {
        
        let vc = wireUp()
        parent.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalWireframeDestination) {

        switch destination {
            
        case .dismiss:
            
            if let navigationController = parent as? NavigationController {
                
                navigationController.popViewController(animated: true)
            } else {
            
                parent.navigationController?.popViewController(animated: true)
            }
        }
    }
}

private extension DefaultCultProposalWireframe {

    func wireUp() -> UIViewController {
        
        let vc: CultProposalViewController = UIStoryboard(.cultProposal).instantiate()
        let presenter = DefaultCultProposalPresenter(
            view: vc,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        return vc
    }
}
