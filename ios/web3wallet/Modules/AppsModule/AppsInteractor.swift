// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AppsInteractor: AnyObject {

}

// MARK: - DefaultAppsInteractor

class DefaultAppsInteractor {


    private var AppsService: AppsService

    init(_ AppsService: AppsService) {
        self.AppsService = AppsSerice
    }
}

// MARK: - DefaultAppsInteractor

extension DefaultAppsInteractor: AppsInteractor {

}
