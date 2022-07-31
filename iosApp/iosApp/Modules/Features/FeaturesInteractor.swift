// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol FeaturesInteractor: AnyObject {

    func fetchAllFeatures(
        onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void
    )
}

final class DefaultFeaturesInteractor {

    private let featureService: FeaturesService

    init(featureService: FeaturesService) {
        
        self.featureService = featureService
    }
}

extension DefaultFeaturesInteractor: FeaturesInteractor {

    func fetchAllFeatures(
        onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void
    ) {
        
        featureService.fetchAllFeatures(onCompletion: onCompletion)
    }
}
