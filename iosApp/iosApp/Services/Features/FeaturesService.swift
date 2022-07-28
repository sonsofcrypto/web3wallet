// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

struct Web3Feature {
    
    let title: String
    let body: String
    let image: Data
    let category: Category
    
    enum Category {
        
        case infrastructure
        case integrations
        case features
    }
}

protocol FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void)
}

final class DefaultFeaturesService {
    
}

extension DefaultFeaturesService: FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            guard let self = self else { return }
            onCompletion(.success(self.allFeatures))
        }
    }
}

private extension DefaultFeaturesService {
    
    var allFeatures: [Web3Feature] {
        
        [
            .init(
                title: "Feature 1",
                body: "This is actually much cooler that you may think. Stay tunned!",
                image: "dashboard-palm".assetImage!.pngData()!,
                category: .infrastructure
            )
        ]
    }
}
