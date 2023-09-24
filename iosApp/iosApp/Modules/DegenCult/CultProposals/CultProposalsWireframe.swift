// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCultProposalsWireframe {
    private weak var parent: UIViewController?
    private let cultProposalWireframeFactory: CultProposalWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
    private let cultService: CultService
    private let walletService: WalletService
    private let networksService: NetworksService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        cultProposalWireframeFactory: CultProposalWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        cultService: CultService,
        walletService: WalletService,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.cultProposalWireframeFactory = cultProposalWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.cultService = cultService
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultCultProposalsWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalsWireframeDestination) {
        if let input = destination as? CultProposalsWireframeDestination.Proposal {
            let context = CultProposalWireframeContext(proposal: input.proposal, proposals: input.proposals)
            cultProposalWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? CultProposalsWireframeDestination.CastVote {
            let networkFee = networksService.defaultNetworkFee(network: Network.ethereum())
            let context = ConfirmationWireframeContext.CultCastVote(
                data: .init(cultProposal: input.proposal, approve: input.approve, networkFee: networkFee)
            )
            confirmationWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? CultProposalsWireframeDestination.Alert {
            alertWireframeFactory.make(vc, context: input.context).present()
        }
        if destination is CultProposalsWireframeDestination.GetCult {
            let context = CurrencySwapWireframeContext(
                network: .ethereum(), currencyFrom: nil, currencyTo: Currency.Companion().cult()
            )
            currencySwapWireframeFactory.make(vc, context: context).present()
        }
    }
}

private extension DefaultCultProposalsWireframe {

    func wireUp() -> UIViewController {
        let vc: CultProposalsViewController = UIStoryboard(.cultProposals).instantiate()
        let interactor = DefaultCultProposalsInteractor(
            cultService: cultService,
            walletService: walletService
        )
        let presenter = DefaultCultProposalsPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
