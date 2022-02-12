// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol MnemonicsInteractor {

    typealias MnemonicsInteractorHandler = ([Mnemonic]) -> Void

    func loadMnemonics(_ handler: MnemonicsInteractorHandler)
    func generateNewMnemonic(password: String, passphrase: String?)
    func addMnemonic(_ mnemonic: Mnemonic)
    func delete(_ mnemonic: Mnemonic)
}

// MARK: - DefaultMnemonicsInteractor

class DefaultMnemonicsInteractor {


}

// MARK: - MnemonicsInteractor

extension DefaultMnemonicsInteractor: MnemonicsInteractor {

    func loadMnemonics(_ handler: MnemonicsInteractorHandler) {

    }

    func generateNewMnemonic(password: String, passphrase: String?) {

    }

    func addMnemonic(_ mnemonic: Mnemonic) {

    }

    func delete(_ mnemonic: Mnemonic) {

    }
}
