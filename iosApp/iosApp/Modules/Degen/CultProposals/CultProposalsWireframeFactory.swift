// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe
}

// MARK: - DefaultTemplateWireframeFactory

class DefaultCultProposalsWireframeFactory {

    private let service: CultService


    init(service: CultService) {
        self.service = service
    }
}

// MARK: - TemplateWireframeFactory

extension DefaultCultProposalsWireframeFactory: CultProposalsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> CultProposalsWireframe {
        DefaultCultProposalsWireframe(
            interactor: DefaultCultProposalsInteractor(service),
            parent: parent
        )
    }
}