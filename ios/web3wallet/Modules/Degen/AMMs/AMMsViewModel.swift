//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

struct AMMsViewModel {
    let dapps: [AMMsViewModel.DApp]
}

// MARK - Item

extension AMMsViewModel {

    struct DApp {
        let title: String
        let network: String
        let image: String
    }
}
