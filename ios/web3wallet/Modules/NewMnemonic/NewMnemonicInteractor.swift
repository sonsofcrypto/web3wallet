// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NewMnemonicInteractor: AnyObject {

}

// MARK: - DefaultTemplateInteractor

class DefaultTemplateInteractor {


    private var templateService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        self.templateService = keyStoreService
    }
}

// MARK: - DefaultTemplateInteractor

extension DefaultTemplateInteractor: NewMnemonicInteractor {

}
