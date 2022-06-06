// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CultProposalViewModel {

    let title: String
    let guardian: String
    let summary: String
    let wallet: String

    init(_ proposal: CultProposal) {
        title = "Proposal \(proposal.id): \(proposal.title)"

        guardian = """
                   name: \(proposal.guardianName)
                   social: \(proposal.guardianSocial)
                   wallet: \(proposal.guardianName)
                   """

        summary = """
                  \(proposal.projectSummary) \n
                  \(proposal.socials)
                  """ + proposal.socials
                    .map { $0.relativeString }
                    .reduce("", { $0 + $1 + "\n" })
                  + "\n" + proposal.audits

        wallet = """
                 cult reward: \(proposal.cultReward)
                 distribution: \(proposal.rewardDistributions)
                 wallet: \(proposal.wallet)
                 """
    }
}
