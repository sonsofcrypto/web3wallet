// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposal {
    let title: String
    let id: Int
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
}

extension CultProposal {

    static func mock(with title: String, id: Int) -> CultProposal {
        .init(
            title: title,
            id: id,
            approved: 28126112668.969,
            rejeceted: 16583879978.515,
            totalVotes: 44709992647.485,
            endDate: Date().addingTimeInterval(Double.random(in: 0..<1000000)),
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
            wallet: "0x9aA80dCeD760224d59BEFe358c7C66C45e3BEA1C"
        )
    }

    static func closedMocks() -> [CultProposal] {
        return [
            mock(with: "Mock proposal", id: 41),
            mock(with: "Web3 wallet", id: 40),
            mock(with: "Another proposal", id: 39),
            mock(with: "Mock project", id: 38),
        ]
    }

    static func pendingProposals() -> [CultProposal] {
        return [
            .init(
                title: "Mock Proposal",
                id: 41,
                approved: 28126112668.969,
                rejeceted: 16583879978.515,
                totalVotes: 44709992647.485,
                endDate: Date(timeIntervalSince1970: 0),
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
                wallet: "0x9aA80dCeD760224d59BEFe358c7C66C45e3BEA1C"
            ),
        ]
    }
}
