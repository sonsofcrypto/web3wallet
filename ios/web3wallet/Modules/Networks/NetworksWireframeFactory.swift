//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

final class DefaultNetworksWireframeFactory {

    private let networksService: NetworksService

    init(
        networksService: NetworksService
    ) {
        self.networksService = networksService
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        DefaultNetworksWireframe(
            parent: parent,
            interactor: DefaultNetworksInteractor(networksService)
        )
    }
}
