// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

protocol ConfirmationInteractor {
    
    func send(
        tokenFrom: Web3Token,
        toAddress: String,
        balance: BigInt,
        fee: Web3NetworkFee,
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
        balance: BigInt,
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
                amount: balance,
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
        password: String,
        salt: String,
        handler: @escaping (Result<TransactionResponse, Error>) -> Void
    ) {
        let address = ""
        let from = ""
        let to = ""
        let network: Network! = nil
        let tokenId = 0

        do {
            try walletService.unlock(
                password: password,
                salt: salt,
                network: network
            )
            let contract = ERC721(address: Address.HexString(hexString: address))
            walletService.contractSend(
                contractAddress: contract.address.hexString,
                data: contract.transferFrom(
                    from: Address.HexString(hexString: from),
                    to: Address.HexString(hexString: to),
                    tokenId: BigInt.Companion().from(long: Int64(tokenId))
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
}

enum ConfirmationInteractorError: Error {
    case noResponse
}