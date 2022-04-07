//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol NFTsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NFTsWireframe
}

final class DefaultNFTsWireframeFactory {

    private let service: NFTsService

    private weak var window: UIWindow?

    init(
        service: NFTsService
    ) {
        self.service = service
    }
}

extension DefaultNFTsWireframeFactory: NFTsWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NFTsWireframe {
        DefaultNFTsWireframe(
            parent: parent,
            interactor: DefaultNFTsInteractor(service)
        )
    }
}
