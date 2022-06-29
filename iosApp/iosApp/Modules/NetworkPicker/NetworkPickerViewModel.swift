// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NetworkPickerViewModel {
    
    let title: String
    let items: [Item]
    
    struct Item {
        
        let image: UIImage?
        let name: String
    }
}
