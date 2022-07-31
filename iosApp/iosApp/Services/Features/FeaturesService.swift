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
    let creationDate: Date
    let endDate: Date
    
    enum Category {
        
        case infrastructure
        case integrations
        case features
    }
}

extension Web3Feature.Category {
    
    var stringValue: String {
        
        switch self {
            
        case .infrastructure:
            return Localized("features.segmentedControl.infrastructure")
        case .integrations:
            return Localized("features.segmentedControl.integrations")
        case .features:
            return Localized("features.segmentedControl.infrastructure")
        }
    }
}

protocol FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void)
}

final class DefaultFeaturesService {
    
}

extension DefaultFeaturesService: FeaturesService {
    
    func fetchAllFeatures(onCompletion: @escaping (Result<[Web3Feature], Error>) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
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
                approved: 0,
                rejeceted: 0,
                category: .infrastructure,
                creationDate: Date(),
                endDate: Date().addingTimeInterval(2*24*60*60)
            ),
            .init(
                id: "2",
                title: "Feature 2",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm".assetImage!.pngData()!,
                approved: 23,
                rejeceted: 23,
                category: .infrastructure,
                creationDate: Date().addingTimeInterval(-8*24*60*60),
                endDate: Date().addingTimeInterval(5*24*60*60)
            ),
            .init(
                id: "3",
                title: "Feature 3",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm".assetImage!.pngData()!,
                approved: 79,
                rejeceted: 23,
                category: .integrations,
                creationDate: Date().addingTimeInterval(-5*24*60*60),
                endDate: Date().addingTimeInterval(24*60*60)
            ),
            .init(
                id: "4",
                title: "Feature 4",
                body: "Anoon will this with exciting details, this is gonna be a very long description, he loves to write!",
                image: "dashboard-palm".assetImage!.pngData()!,
                approved: 79,
                rejeceted: 23,
                category: .features,
                creationDate: Date().addingTimeInterval(-2*24*60*60),
                endDate: Date().addingTimeInterval(2*24*60*60)
            )
        ]
    }
}
