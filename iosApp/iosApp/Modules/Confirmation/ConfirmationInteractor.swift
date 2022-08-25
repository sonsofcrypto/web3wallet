// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

protocol ConfirmationInteractor {
    
    func send(
        tokenFrom: Web3Token,
        toAddress: String,
        amount: BigInt,
        fee: Web3NetworkFee,
        password: String,
        salt: String,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    )

    func sendNFT(
        from: String,
        to: String,
        nft: NFTItem,
        password: String,
        salt: String,
        network: Network,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    )
    
    func castVote(
        proposalId: String,
        support: Bool,
        password: String,
        salt: String,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    )
}

final class DefaultConfirmationInteractor {

    private let walletService: WalletService

    init(walletService: WalletService) {
        self.walletService = walletService
    }
}

extension DefaultConfirmationInteractor: ConfirmationInteractor {
    
    func send(
        tokenFrom: Web3Token,
        toAddress: String,
        amount: BigInt,
        fee: Web3NetworkFee,
        password: String,
        salt: String,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    ) {
        do {
            try walletService.unlock(
                password: password,
                salt: salt,
                network: tokenFrom.network.toNetwork()
            )

            walletService.transfer(
                to: toAddress,
                currency: tokenFrom.toCurrency(),
                amount: amount,
                network: tokenFrom.network.toNetwork(),
                completionHandler: { response, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let response = response else {
                        handler(.failure(ConfirmationInteractorError.noResponse))
                        return
                    }
                    handler(.success(response))
                }
            )

        } catch {
            handler(.failure(error))
        }
    }

    func sendNFT(
        from: String,
        to: String,
        nft: NFTItem,
        password: String,
        salt: String,
        network: Network,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    ) {
        guard let tokenIdInt = try? nft.tokenId.int() else {
            handler(.failure(ConfirmationInteractorError.failedToParseTokenId))
            return
        }
        do {
            try walletService.unlock(
                password: password,
                salt: salt,
                network: network
            )
            let contract = ERC721(address: Address.HexString(hexString: nft.address))
            walletService.contractSend(
                contractAddress: contract.address.hexString,
                data: contract.transferFrom(
                    from: Address.HexString(hexString: from),
                    to: Address.HexString(hexString: to),
                    tokenId: BigInt.Companion().from(long: Int64(tokenIdInt))
                ),
                network: network,
                completionHandler: { response, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let response = response else {
                        handler(.failure(ConfirmationInteractorError.noResponse))
                        return
                    }
                    handler(.success(response))
                }
            )
        } catch {
            handler(.failure(error))
        }
    }
    
    func castVote(
        proposalId: String,
        support: Bool,
        password: String,
        salt: String,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    ) {
        do {
            
            guard let id = try? proposalId.int() else {
                handler(.failure(ConfirmationInteractorError.failedProposalId))
                return
            }

            let network = Network.ethereum()
            try walletService.unlock(
                password: password,
                salt: salt,
                network: network
            )

            let contract = CultGovernor()
            let supportInt = UInt32(support ? 1 : 0)

            walletService.contractSend(
                contractAddress: contract.address.hexString,
                data: contract.castVote(proposalId: UInt32(id), support: supportInt),
                network: network,
                completionHandler:  { response, error in
                    if let error = error {
                        handler(.failure(error))
                        return
                    }
                    guard let response = response else {
                        handler(.failure(ConfirmationInteractorError.noResponse))
                        return
                    }
                    handler(.success(response))
                }
            )
        } catch {
            handler(.failure(error))
        }
    }
}

enum ConfirmationInteractorError: Error {
    case noResponse
    case failedToParseTokenId
    case failedProposalId
}
