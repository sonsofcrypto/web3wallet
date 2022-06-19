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
    let network: Item
    let contractAddress: TextFieldItem
    let name: TextFieldItem
    let symbol: TextFieldItem
    let decimals: TextFieldItem
    
    struct Item {
        
        let name: String
        let value: String?
    }
    
    struct TextFieldItem {
        
        let item: Item
        let placeholder: String
        let hint: String?
        let tag: Int
        let onTextChanged: (TextFieldType, String) -> Void
        let onReturnTapped: (TextFieldType) -> Void
        let onScanAction: ((TextFieldType) -> Void)?
        let isFirstResponder: Bool
    }
}
