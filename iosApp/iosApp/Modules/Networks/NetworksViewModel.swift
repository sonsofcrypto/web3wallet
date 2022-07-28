// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NetworksViewModel {
    
    case loaded(header: String, networks: [Network])
    case error(error: NetworksViewModel.Error)
}

extension NetworksViewModel {

    struct Network {

        let networkId: String
        let iconName: String
        let name: String
        let connectionType: String
        let status: String
        let explorer: String
        let connected: Bool?
    }
}

extension NetworksViewModel {

    struct Error {
        
        let title: String
        let body: String
        let actions: [String]
    }
}

extension NetworksViewModel {
    
    var header: String {
        
        switch self {
        case let .loaded(header, _):
            return header
        default:
            return ""
        }
    }

    func network() -> [NetworksViewModel.Network] {
        
        switch self {
        case let .loaded(_, items):
            return items
        default:
            return []
        }
    }
}
