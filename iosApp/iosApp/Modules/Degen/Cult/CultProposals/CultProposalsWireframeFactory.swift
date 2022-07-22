// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe
}

final class DefaultCultProposalsWireframeFactory {

    private let service: CultService
    private let factory: CultProposalWireframeFactory

    init(
        service: CultService,
        cultProposalWireframeFactory: CultProposalWireframeFactory
    ) {
        self.service = service
        self.factory = cultProposalWireframeFactory
    }
}

extension DefaultCultProposalsWireframeFactory: CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe {
        DefaultCultProposalsWireframe(
            interactor: DefaultCultProposalsInteractor(service),
            parent: parent,
            factory: factory
        )
    }
}
