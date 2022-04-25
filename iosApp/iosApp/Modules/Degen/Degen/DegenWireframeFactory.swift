// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe
}

final class DefaultDegenWireframeFactory {

    private let degenService: DegenService
    private let ammsWireframeFactory: AMMsWireframeFactory

    init(
        degenService: DegenService,
        ammsWireframeFactory: AMMsWireframeFactory
    ) {
        self.degenService = degenService
        self.ammsWireframeFactory = ammsWireframeFactory
    }
}

extension DefaultDegenWireframeFactory: DegenWireframeFactory {

    func makeWireframe(_ parent: TabBarController) -> DegenWireframe {
        
        DefaultDegenWireframe(
            parent: parent,
            degenService: degenService,
            ammsWireframeFactory: ammsWireframeFactory
        )
    }
}
