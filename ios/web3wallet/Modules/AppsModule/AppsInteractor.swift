// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AppsInteractor: AnyObject {

}

final class DefaultAppsInteractor {


    private var appsService: AppsService

    init(
        appsService: AppsService
    ) {
        
        self.appsService = appsService
    }
}

extension DefaultAppsInteractor: AppsInteractor {

}
