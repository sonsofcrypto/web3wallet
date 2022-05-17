// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AccountService: AnyObject {

    var mnemonicWords: [String] { get }
    func validateMnemonic(with mnemonic: String) -> Bool
}
