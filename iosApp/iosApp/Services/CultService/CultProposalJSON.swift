// Created by web3d4v on 25/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposalServiceJSON: Codable {
    enum CodingKeys: String, CodingKey {
        case proposals = "data"
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
        let range: String
        let rate: String
        let time: String
        //let checkbox1: Bool
        //let checkbox2: Bool
        let wallet: String
        let guardianProposal: String?
        let guardianDiscord: String?
        let guardianAddress: String?
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CultProposalJSON.Description.CodingKeys> = try decoder.container(keyedBy: CultProposalJSON.Description.CodingKeys.self)
            self.projectName = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.projectName)
            self.shortDescription = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.shortDescription)
            self.file = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.file)
            self.socialChannel = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.socialChannel)
            self.links = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.links)
            if let range = try? container.decode(Int.self, forKey: CultProposalJSON.Description.CodingKeys.range) {
                self.range = "\(range)"
            } else if let range = try? container.decode(Double.self, forKey: CultProposalJSON.Description.CodingKeys.range) {
                self.range = range.toString(decimals: 2).replacingOccurrences(of: ".00", with: "")
            } else if let range = try? container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.range) {
                self.range = "\(range)"
            } else {
                self.range = ""
            }
            self.rate = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.rate)
            self.time = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.time)
            self.wallet = try container.decode(String.self, forKey: CultProposalJSON.Description.CodingKeys.wallet)
            self.guardianProposal = try container.decodeIfPresent(String.self, forKey: CultProposalJSON.Description.CodingKeys.guardianProposal)
            self.guardianDiscord = try container.decodeIfPresent(String.self, forKey: CultProposalJSON.Description.CodingKeys.guardianDiscord)
            self.guardianAddress = try container.decodeIfPresent(String.self, forKey: CultProposalJSON.Description.CodingKeys.guardianAddress)
        }
    }
}
