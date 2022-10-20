// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CurrencyAddViewModel {
    
    enum TextFieldType: Int {
        case contractAddress
        case name
        case symbol
        case decimals
    }
    
    let title: String
    let network: NetworkItem
    let contractAddress: TextFieldItem
    let name: TextFieldItem
    let symbol: TextFieldItem
    let decimals: TextFieldItem
    let saveButtonTitle: String
    let saveButtonEnabled: Bool
        
    struct NetworkItem {
        let name: String
        let value: String?
    }
    
    struct TextFieldItem {
        let name: String
        let value: String?
        let placeholder: String
        let hint: String?
        let tag: Int
        let isFirstResponder: Bool
    }

}
