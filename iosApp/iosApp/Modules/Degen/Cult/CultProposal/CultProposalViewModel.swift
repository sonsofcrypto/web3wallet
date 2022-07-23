// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposalViewModel {

    let title: String
    let proposals: [ProposalDetails]
    let selectedIndex: Int

    struct ProposalDetails {
        
        let name: String
        let guardianInfo: GuardianInfo
        let summary: String
        let documents: [DocumentsInfo]
        let rewardAllocation: String
        let rewardDistribution: String
        let projectETHWallet: String
        
        struct GuardianInfo {
            
            let name: String
            let socialHandle: String
            let wallet: String
        }
        
        struct DocumentsInfo {
            
            let name: String
            let note: String?
            let documents: [Document]
            
            struct Document {
                
                let displayName: String
                let url: URL
            }
        }
    }
    
    var titleIcon: Data {
        
        UIImage(named: "degen-cult-icon")!.pngData()!
    }
}
