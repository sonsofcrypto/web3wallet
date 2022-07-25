// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum CultServiceErrors: Error {
    
    case unableToFetch
}

protocol CultService {
    
    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    )
}

final class DefaultCultService {
    
    let web3Service: Web3Service
    
    init(web3Service: Web3Service) {
        
        self.web3Service = web3Service
    }
}

extension DefaultCultService: CultService {

    func fetchProposals(
        onCompletion: @escaping (Result<[CultProposal], Error>) -> Void
    ) {
        
        guard let url = URL(string: "https://api.cultdao.io/static/proposals.json") else {
            
            onCompletion(.failure(CultServiceErrors.unableToFetch))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    
                    onCompletion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    
                    onCompletion(.failure(CultServiceErrors.unableToFetch))
                    return
                }
                
                do {
                    
                    let result = try JSONDecoder().decode(CultProposalServiceJSON.self, from: data)
                    onCompletion(.success(self.makeCultProposals(from: result.proposals)))
                    
                } catch let error {
                    
                    onCompletion(.failure(error))
                }
            }
        }.resume()
    }
   
}

private extension DefaultCultService {
    
    func makeCultProposals(from proposals: [CultProposalJSON]) -> [CultProposal] {
        
        proposals.compactMap { makeCultProposal(from: $0) }
    }
    
    func makeCultProposal(from proposal: CultProposalJSON) -> CultProposal? {
        
        guard let status = makeStatus(from: proposal) else { return nil }
        
        return .init(
            id: proposal.id,
            title: proposal.description.projectName,
            approved: makeApprovedVotes(from: proposal),
            rejeceted: makeRejectedVotes(from: proposal),
            endDate: makeEndDate(from: proposal),
            guardianInfo: makeGuardianInfo(from: proposal.description),
            projectSummary: proposal.description.shortDescription,
            projectDocuments: makeProjectDocuments(from: proposal),
            cultReward: makeCultReward(from: proposal.description),
            rewardDistributions: makeRewardDistribution(from: proposal.description),
            wallet: proposal.description.wallet,
            status: status
        )
    }
    
    func makeStatus(
        from proposal: CultProposalJSON
    ) -> CultProposal.Status? {
        
        let currentBlock = web3Service.currentEthBlock
        
        guard proposal.startBlock < currentBlock else { return nil }
        
        if proposal.endBlock > currentBlock {
            
            return .pending
        } else {
            
            return .closed
        }
    }
    
    func makeGuardianInfo(
        from project: CultProposalJSON.Description
    ) -> CultProposal.GuardianInfo? {
    
        guard
            let proposal = project.guardianProposal,
            let discord = project.guardianDiscord,
            let address = project.guardianAddress
        else {
            
            return nil
        }
        
        return .init(
            proposal: proposal,
            discord: discord,
            address: address
        )
    }
    
    func makeProjectDocuments(
        from proposal: CultProposalJSON
    ) -> [CultProposal.ProjectDocuments] {
     
        []
    }
    
    func makeApprovedVotes(
        from proposal: CultProposalJSON
    ) -> Double {
        
        (Double(proposal.forVotes) ?? 0) * 0.000000000000000001
    }

    func makeRejectedVotes(
        from proposal: CultProposalJSON
    ) -> Double {
        
        (Double(proposal.againstVotes) ?? 0) * 0.000000000000000001
    }

    func makeEndDate(
        from proposal: CultProposalJSON
    ) -> Date {
        
        let genesisEpocOffset = 1460999972
        
        let epocEndBlock = (Int(proposal.endBlock) ?? 0) * 13
        return Date(timeIntervalSince1970: TimeInterval(genesisEpocOffset + epocEndBlock))
    }
    
    func makeCultReward(
        from description: CultProposalJSON.Description
    ) -> String {
        
        return Localized(
            "cult.proposal.parsing.cultRewardAllocation",
            arg: description.range.toString(
                decimals: 2
            )
        )
    }
    
    func makeRewardDistribution(
        from description: CultProposalJSON.Description
    ) -> String {
        
        let perString = Localized("cult.proposal.parsing.rewardDistribution.per")
        let rate = description.rate.replacingOccurrences(of: "%", with: "")
        return rate + "%" + perString + " " + description.time
    }
}
