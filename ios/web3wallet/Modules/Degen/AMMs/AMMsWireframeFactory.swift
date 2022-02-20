// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AMMsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AMMsWireframe
}

// MARK: - DefaultAMMsWireframeFactory

class DefaultAMMsWireframeFactory {

    private let degenService: DegenService
    private let swapWireframeFactory: SwapWireframeFactory

    init(
        degenService: DegenService,
        swapWireframeFactory: SwapWireframeFactory
    ) {
        self.degenService = degenService
        self.swapWireframeFactory = swapWireframeFactory
    }
}

// MARK: - AMMsWireframeFactory

extension DefaultAMMsWireframeFactory: AMMsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> AMMsWireframe {
        DefaultAMMsWireframe(
            parent: parent,
            interactor: DefaultAMMsInteractor(degenService),
            swapWireframeFactory: swapWireframeFactory
        )
    }
}