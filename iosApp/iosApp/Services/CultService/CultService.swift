// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum CultServiceError: Error {
    case unableToFetch
    case failedProposalId
    case noResponse
}

typealias CultProposalsResponse = (pending: [CultProposal], closed: [CultProposal])

protocol CultService {
    func fetchProposals(
        handler: @escaping (Result<CultProposalsResponse, Error>) -> Void
    )
}

final class DefaultCultService {
    let walletService: WalletService
    
    init(walletService: WalletService) {
        self.walletService = walletService
    }
}

extension DefaultCultService: CultService {

    func fetchProposals(handler: @escaping (Result<CultProposalsResponse, Error>) -> Void) {
        fetchPending(handler: handler)
    }
}

private extension DefaultCultService {
    
    func fetchPending(handler: @escaping (Result<CultProposalsResponse, Error>) -> Void) {
        fetchProposals(type: "pending") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(pending):
                self.fetchClosed(pending: pending, handler: handler)
            case .failure:
                self.fetchClosed(pending: [], handler: handler)
            }
        }
    }
    
    func fetchClosed(
        pending: [CultProposal],
        handler: @escaping (Result<CultProposalsResponse, Error>) -> Void
    ) {
        fetchProposals(type: "closed") { result in
            var closed = [CultProposal]()
            switch result {
            case let .success(proposals): closed = proposals
            case .failure: break
            }
            handler(.success((pending: pending, closed: closed)))
        }
    }
    
    func fetchProposals(type: String, handler: @escaping (Result<[CultProposal], Error>) -> Void) {
        guard let url = URL(string: "https://api.cultdao.io/proposals/\(type)") else {
            handler(.failure(CultServiceError.unableToFetch))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error { return handler(.failure(error)) }
                guard let data = data else { return handler(.failure(CultServiceError.unableToFetch)) }
                do {
                    let result = try JSONDecoder().decode(CultProposalServiceJSON.self, from: data)
                    handler(.success(self.cultProposals(from: result.proposals)))
                } catch let error {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    func cultProposals(from proposals: [CultProposalJSON]) -> [CultProposal] {
        proposals.compactMap { cultProposal(from: $0) }
    }
    
    func cultProposal(from proposal: CultProposalJSON) -> CultProposal? {
        guard let status = status(from: proposal) else { return nil }
        return .init(
            id: proposal.id,
            title: "#" + proposal.id + " " + proposal.description.projectName,
            approved: approvedVotes(from: proposal),
            rejeceted: rejectedVotes(from: proposal),
            endDate: endDate(from: proposal),
            guardianInfo: guardianInfo(from: proposal.description),
            projectSummary: proposal.description.shortDescription,
            projectDocuments: projectDocuments(from: proposal),
            cultReward: cultReward(from: proposal.description),
            rewardDistributions: rewardDistribution(from: proposal.description),
            wallet: proposal.description.wallet,
            status: status,
            stateName: proposal.stateName
        )
    }
    
    func status(from proposal: CultProposalJSON) -> CultProposal.Status? {
        let currentBlock = walletService.blockNumber(network: Network.ethereum())
        guard proposal.startBlock < currentBlock.toDecimalString() else { return nil }
        if proposal.endBlock > currentBlock.toDecimalString() { return .pending
        } else { return .closed }
    }
    
    func guardianInfo(from project: CultProposalJSON.Description) -> CultProposal.GuardianInfo? {
        guard
            let proposal = project.guardianProposal,
            let discord = project.guardianDiscord,
            let address = project.guardianAddress
        else { return nil }
        return .init(
            proposal: proposal,
            discord: discord,
            address: address
        )
    }
    
    func projectDocuments(from proposal: CultProposalJSON) -> [CultProposal.ProjectDocuments] {
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
    
    func approvedVotes(from proposal: CultProposalJSON) -> Double {
        (Double(proposal.forVotes) ?? 0) * 0.000000000000000001
    }

    func rejectedVotes(from proposal: CultProposalJSON) -> Double {
        (Double(proposal.againstVotes) ?? 0) * 0.000000000000000001
    }

    func endDate(from proposal: CultProposalJSON) -> Double {
        let genesisEpocOffset = 1460999972
        let epocEndBlock = (Int(proposal.endBlock) ?? 0) * 13
        return Double(genesisEpocOffset + epocEndBlock)
    }
    
    func cultReward(from description: CultProposalJSON.Description) -> String {
        Localized(
            "cult.proposal.parsing.cultRewardAllocation",
            description.range
        )
    }
    
    func rewardDistribution(from description: CultProposalJSON.Description) -> String {
        let perString = Localized("cult.proposal.parsing.rewardDistribution.per")
        let rate = description.rate.replacingOccurrences(of: "%", with: "")
        return rate + "% " + perString + " " + description.time
    }
}
