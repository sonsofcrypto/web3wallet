//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol NFTsInteractor: AnyObject {

}

// MARK: - DefaultNFTsInteractor

class DefaultNFTsInteractor {


    private var service: NFTsService

    init(_ service: NFTsService) {
        self.service = service
    }
}

// MARK: - DefaultNFTsInteractor

extension DefaultNFTsInteractor: NFTsInteractor {

}
