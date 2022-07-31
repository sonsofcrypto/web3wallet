// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

struct Web3Feature {
    
    let id: String
    let title: String
    let body: String
    let image: Data
    let approved: Double
    let rejeceted: Double
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
                id: "1",
                title: "Feature 1",
                body: "This is actually much cooler that you may think. Stay tunned!",
                image: "dashboard-palm".assetImage!.pngData()!,
                approved: 65,
                rejeceted: 23,
                category: .infrastructure
            ),
            .init(
                id: "2",
                title: "Feature 2",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm".assetImage!.pngData()!,
                approved: 23,
                rejeceted: 23,
                category: .infrastructure
            )
        ]
    }
}
