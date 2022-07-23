// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposal {
    
    let id: Int
    let title: String
    let approved: Float
    let rejeceted: Float
    let totalVotes: Float
    let endDate: Date
    
    let guardianName: String
    let guardianSocial: String
    let guardianWallet: String

    let projectSummary: String
    let whitepaper: URL?
    let socials: [URL]
    let audits: String
    
    let cultReward: Float
    let rewardDistributions: Float
    let wallet: String
    let category: Category
    
    enum Category {
        case none
        case new
    }
}

extension CultProposal {

    static func mock(
        id: Int,
        with title: String,
        approved: Float = 28126112668.969,
        rejected: Float = 16583879978.515,
        endDate: Date = Date().addingTimeInterval(Double.random(in: 0..<1000000)),
        category: Category = .none
    ) -> CultProposal {
        .init(
            id: id,
            title: title,
            approved: approved,
            rejeceted: rejected,
            totalVotes: approved + rejected,
            endDate: endDate,
            guardianName: "Kely Chasse",
            guardianSocial: "@kyle_chasse",
            guardianWallet: "0x5B8235604885B9Fb34e6DDe5d8b47fb92C0371A9",
            projectSummary: """
                            Note : This was provided to me by team, I am NOT part of the team, just a very excited supporter. Description: First truly web3 wallet, that does not compromise an iota on crypto ideals. By degens for degens. - Virtually all the wallets connect to networks via web2 services. That's flat out embarrassing. We are putting an end to that. - Anything web3 / DeFi sucks on mobile and is indeed out of reach for non crypto natives. Normies do everything on mobile. There is an easy 10x for whole space once it is easy to use on mobile. We are building in large directory of all the categories of DeFi products. - All the fees generated in apps will go to token LP stakers trustlessly via yield farm. Hence giving token a floor price which is a function of usage of the apps. - Fair launch, not presale, team only gets rich if product has wide adoption and usage. - All the code is open source MIT licensed Kyle's comments on investment opportunity: - NO VCs - CULT will be the only pre-sale in the world at an amazing Valuation of only $4,000,000 FDV. Netting us nearly 1% of the total supply, imagine if metamask had a token with excellent tokenomics and CULT had 1%
                            """,
            whitepaper: URL(string: "https://sonsofcrypto.com/web3token_whitepaper.pdf")!,
            socials: [
                URL(string: "https://twitter.com/sonsofcryptolab")!,
                URL(string: "https://discord.gg/ptJGvwGkEj")!,
                URL(string: "https://t.me/+osHUInXKmwMyZjQ0")!,
                URL(string: "https://github.com/sonsofcrypto")!,
            ],
            audits: "Not done yet, this is presale, of course quality audits will be done. But here is link to contract: https://github.com/sonsofcrypto/w3t",
            cultReward: 1,
            rewardDistributions: 6.25,
            wallet: "0x9aA80dCeD760224d59BEFe358c7C66C45e3BEA1C",
            category: category
        )
    }

    static func closedMocks() -> [CultProposal] {
        
        [
            mock(
                id: 61,
                with: "Proposal 41: Giveth Regen Farm",
                approved: 16848805234.234,
                rejected: 13347199621.322,
                endDate: Date().addingTimeInterval(-16*24*60*60)
            ),
            mock(
                id: 62,
                with: "Proposal 40: Web3 wallet",
                approved: 28126112668.969,
                rejected: 16583879978.515,
                endDate: Date().addingTimeInterval(-19*24*60*60)
            ),
            mock(
                id: 63,
                with: "Proposal 39: Giveth Regen Farm",
                approved: 18126112668.969,
                rejected: 60583879978.515,
                endDate: Date().addingTimeInterval(-25*24*60*60)
            ),
            mock(
                id: 64,
                with: "Proposal 38: Inverse Finance Yield Farming",
                approved: 19213120713.966,
                rejected: 17674640646.963,
                endDate: Date().addingTimeInterval(-30*24*60*60)
            )
        ]
    }

    static func pendingProposals() -> [CultProposal] {
        
        [
            mock(
                id: 41,
                with: "Proposal 42: ChainLink",
                approved: 38126112668.969,
                rejected: 6583879978.515,
                endDate: Date().addingTimeInterval(16*24*60*60),
                category: .new
            ),
            mock(
                id: 42,
                with: "Proposal 43: History (token)",
                approved: 28126112668.969,
                rejected: 66583879978.515,
                endDate: Date().addingTimeInterval(15*24*60*60),
                category: .new
            ),
            mock(
                id: 43,
                with: "Proposal 44: Verasity - Allocation #1",
                approved: 12058527010.969,
                rejected: 2058527010.515,
                endDate: Date().addingTimeInterval(2*24*60*60)
            )
        ]
    }
}
