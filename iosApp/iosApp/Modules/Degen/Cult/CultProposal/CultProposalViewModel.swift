// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

struct CultProposalViewModel {

    let title: String
    let proposals: [ProposalDetails]
    let selectedIndex: Int

    struct ProposalDetails {
        
        let name: String
        let status: Status
        let guardianInfo: GuardianInfo?
        let summary: Summary
        let documentsInfo: DocumentsInfo
        let tokenomics: Tokenomics
        
        struct GuardianInfo {
            
            let title: String
            let name: String
            let nameValue: String
            let socialHandle: String
            let socialHandleValue: String
            let wallet: String
            let walletValue: String
        }
        
        struct Status {
            
            let title: String
            let color: UIColor // HEX
        }
        
        struct Summary {
            
            let title: String
            let summary: String
        }
        
        struct DocumentsInfo {
            
            let title: String
            let documents: [Document]
            
            struct Document {
                
                let title: String
                let items: [Item]
                
                enum Item {
                    
                    case link(displayName: String, url: URL)
                    case note(String)
                }
            }
        }
        
        struct Tokenomics {
            
            let title: String
            let rewardAllocation: String
            let rewardAllocationValue: String
            let rewardDistribution: String
            let rewardDistributionValue: String
            let projectETHWallet: String
            let projectETHWalletValue: String
        }
    }
    
    var titleIcon: Data {
        
        UIImage(named: "degen-cult-icon")!.pngData()!
    }
}
