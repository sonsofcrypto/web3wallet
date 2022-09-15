// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct TokenAddViewModel {
    
    enum TextFieldType: Int {
        case contractAddress
        case name
        case symbol
        case decimals
    }
    
    let title: String
    let network: NetworkItem
    let address: TokenEnterAddressViewModel
    let name: TextFieldItem
    let symbol: TextFieldItem
    let decimals: TextFieldItem
    let saveButtonTitle: String
    
    struct Item {
        let name: String
        let value: String?
    }
    
    struct NetworkItem {
        let item: Item
    }
    
    struct TextFieldItem {
        let item: Item
        let placeholder: String
        let hint: String?
        let tag: Int
        let isFirstResponder: Bool
    }
}
