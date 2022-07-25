// Created by web3d4v on 25/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposalServiceJSON: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case proposals = "PROPOSALS"
    }
    
    let proposals: [CultProposalJSON]
}

struct CultProposalJSON: Codable {
    
    let id: String
    let proposer: String
    let eta: String
    let startBlock: String
    let endBlock: String
    let forVotes: String
    let againstVotes: String
    let abstainVotes: String
    let canceled: Bool
    let executed: Bool
    let description: Description
    let state: String // 1-Active, 2-Cancelled, 3-Defeated, 7-Executed
    let stateName: String
    
    struct Description: Codable {
        
        let projectName: String
        let shortDescription: String
        let file: String
        let socialChannel: String
        let links: String
        let range: Double
        let rate: String
        let time: String
        //let checkbox1: Bool
        //let checkbox2: Bool
        let wallet: String
        let guardianProposal: String?
        let guardianDiscord: String?
        let guardianAddress: String?
    }
}
