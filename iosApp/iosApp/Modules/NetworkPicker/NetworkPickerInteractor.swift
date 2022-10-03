// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol NetworkPickerInteractor: AnyObject {

    var allNetworks: [ Network ] { get }
}

final class DefaultNetworkPickerInteractor {}

extension DefaultNetworkPickerInteractor: NetworkPickerInteractor {
    
    var allNetworks: [Network] {
        NetworksServiceCompanion().supportedNetworks()
    }
}
