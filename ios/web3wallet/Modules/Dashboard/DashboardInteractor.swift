// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol DashboardInteractor: AnyObject {

}

// MARK: - DefaultDashboardInteractor

class DefaultDashboardInteractor {


    private var walletsService: KeyStoreService

    init(_ walletsService: KeyStoreService) {
        self.walletsService = walletsService
    }
}

// MARK: - DefaultDashboardInteractor

extension DefaultDashboardInteractor: DashboardInteractor {

}
