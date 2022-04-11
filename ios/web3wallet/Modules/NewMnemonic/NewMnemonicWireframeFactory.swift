// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NewMnemonicWireframeFactory {

    func makeWireframe(_ parent: UIViewController?) -> NewMnemonicWireframe
}

// MARK: - DefaultNewMnemonicWireframeFactory

class DefaultNewMnemonicWireframeFactory {

    private let service: KeyStoreService

    init(_ service: KeyStoreService) {
        self.service = service
    }
}

// MARK: - NewMnemonicWireframeFactory

extension DefaultNewMnemonicWireframeFactory: NewMnemonicWireframeFactory {

    func makeWireframe(_ parent: UIViewController?) -> NewMnemonicWireframe {
        DefaultNewMnemonicWireframe(
            parent: parent,
            interactor: DefaultTemplateInteractor(service)
        )
    }
}