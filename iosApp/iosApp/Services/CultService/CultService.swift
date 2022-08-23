// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum CultServiceError: Error {
    case unableToFetch
    case failedProposalId
    case noResponse
}

protocol CultService {

    func fetchProposals(
        handler: @escaping (Result<[CultProposal], Error>) -> Void
    )

    func castVote(
        _ id: Int,
        support: Bool,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    )
}

final class DefaultCultService {
    
    let walletService: WalletService
    
    init(walletService: WalletService) {
        self.walletService = walletService
    }
}

extension DefaultCultService: CultService {

    func castVote(
        _ id: Int,
        support: Bool,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    ) {
        let contract = CultGovernor()
        let supportInt = UInt32(support ? 1 : 0)

        walletService.contractSend(
            contractAddress: contract.address.hexString,
            data: contract.castVote(proposalId: UInt32(id), support: supportInt),
            network: Network.ethereum(),
            completionHandler:  { response, error in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let response = response else {
                    handler(.failure(CultServiceError.noResponse))
                    return
                }
                handler(.success(response))
            }
        )
    }

    func fetchProposals(
        handler: @escaping (Result<[CultProposal], Error>) -> Void
    ) {
        
        guard let url = URL(string: "https://api.cultdao.io/static/proposals.json") else {
            
            handler(.failure(CultServiceError.unableToFetch))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    
                    handler(.failure(error))
                    return
                }
                
                guard let data = data else {
                    
                    handler(.failure(CultServiceError.unableToFetch))
                    return
                }
                
                do {
                    
                    let result = try JSONDecoder().decode(CultProposalServiceJSON.self, from: data)
                    handler(.success(self.makeCultProposals(from: result.proposals)))
                    
                } catch let error {
                    
                    handler(.failure(error))
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
            title: "#" + proposal.id + " " + proposal.description.projectName,
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

        let currentBlock = walletService.blockNumber(network: Network.ethereum())

        guard proposal.startBlock < currentBlock.toDecimalString() else { return nil }
        
        if proposal.endBlock > currentBlock.toDecimalString() {
            
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
     
        var documents = [CultProposal.ProjectDocuments]()
        
        if let fileURL = proposal.description.file.url {
        
            documents.append(
                .init(
                    name: Localized("cult.proposals.result.liteWhitepaper"),
                    documents: [
                        .link(
                            displayName: proposal.description.file,
                            url: fileURL
                        )
                    ]
                )
            )
        }
        
        let socialDocs = proposal.description.socialChannel.replacingOccurrences(
            of: "\n", with: " "
        )
        let socialDocsUrls = socialDocs.split(separator: " ").compactMap { String($0).url }
        
        if !socialDocsUrls.isEmpty {
            
            documents.append(
                .init(
                    name: Localized("cult.proposals.result.socialDocs"),
                    documents: socialDocsUrls.compactMap {
                        .link(displayName: $0.absoluteString, url: $0)
                    }
                )
            )
        }

        if let linkURL = proposal.description.links.url {
            
            documents.append(
                .init(
                    name: Localized("cult.proposals.result.audits"),
                    documents: [
                        .link(displayName: linkURL.absoluteString, url: linkURL)
                    ]
                )
            )
        } else if !proposal.description.links.isEmpty {
            
            documents.append(
                .init(
                    name: Localized("cult.proposals.result.audits"),
                    documents: [
                        .note(proposal.description.links)
                    ]
                )
            )
        }
        
        return documents
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
            ).replacingOccurrences(of: ".00", with: "")
        )
    }
    
    func makeRewardDistribution(
        from description: CultProposalJSON.Description
    ) -> String {
        
        let perString = Localized("cult.proposal.parsing.rewardDistribution.per")
        let rate = description.rate.replacingOccurrences(of: "%", with: "")
        return rate + "% " + perString + " " + description.time
    }
}
