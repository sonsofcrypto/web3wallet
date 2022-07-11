// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultAccountService {

}

extension DefaultAccountService: AccountService {
    
    var mnemonicWords: [String] {
        
        [
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
            "ten",
            "eleven",
            "twelve"
        ]
    }

    func validateMnemonic(with mnemonic: String) -> Bool {
        
        mnemonic == "one two three four five six seven eight nine ten eleven twelve"
    }
}
