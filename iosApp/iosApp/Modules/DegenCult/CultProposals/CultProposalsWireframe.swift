// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

enum CultProposalsWireframeDestination {
    case proposal(proposal: CultProposal, proposals: [CultProposal])
    case castVote(proposal: CultProposal, approve: Bool)
    case alert(context: AlertContext)
    case getCult
}

protocol CultProposalsWireframe {
    func present()
    func navigate(to destination: CultProposalsWireframeDestination)
}

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

extension DefaultCultProposalsWireframe: CultProposalsWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: CultProposalsWireframeDestination) {
        switch destination {
        case let .proposal(proposal, proposals):
            let context = CultProposalWireframeContext(proposal: proposal, proposals: proposals)
            cultProposalWireframeFactory.make(vc, context: context).present()
        case let .castVote(proposal, approve):
            let networkFee = networksService.defaultNetworkFee(network: Network.ethereum())
            let context = ConfirmationWireframeContext.CultCastVote(
                data: .init(cultProposal: proposal, approve: approve, networkFee: networkFee)
            )
            confirmationWireframeFactory.make(vc, context: context).present()
        case let .alert(context):
            alertWireframeFactory.make(vc, context: context).present()
        case .getCult:
            // TODO: Review this - we only allow CULT on ETH Mainnet atm...
            currencySwapWireframeFactory.make(
                vc,
                context: .init(
                    network: .ethereum(),
                    currencyFrom: nil,
                    currencyTo: Currency.Companion().cult()
                )
            ).present()
        }
    }
}

private extension DefaultCultProposalsWireframe {

    func wireUp() -> UIViewController {
        let vc: CultProposalsViewController = UIStoryboard(
            .cultProposals
        ).instantiate()
        let interactor = DefaultCultProposalsInteractor(
            cultService,
            walletService: walletService
        )
        let presenter = DefaultCultProposalsPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
