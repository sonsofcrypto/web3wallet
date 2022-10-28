// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposal {
    
    let id: String
    let title: String
    let approved: Double
    let rejeceted: Double
    let endDate: Double // timeIntervalSince1970
    
    let guardianInfo: GuardianInfo?

    let projectSummary: String
    let projectDocuments: [ProjectDocuments]
    
    let cultReward: String
    let rewardDistributions: String
    let wallet: String
    let status: Status
    let stateName: String
    
    struct GuardianInfo {
        
        let proposal: String // aka: name
        let discord: String
        let address: String
    }
        
    struct ProjectDocuments {
        
        let name: String
        let documents: [Document]
        
        enum Document {

            case link(displayName: String, url: URL)
            case note(String)
        }
    }
    
    enum Status {
        case pending
        case closed
    }
}
