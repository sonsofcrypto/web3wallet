// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct MnemonicConfirmationViewModel {
    
    let potentialWords: [String]
    let wordsInfo: [WordInfo]
    let isValid: Bool
    
    struct WordInfo {
        
        let word: String
        let isInvalid: Bool
    }
}
