// Created by web3d4v on 10/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol ConfirmationInteractor {
    
    func send(
        tokenFrom: Web3Token,
        toAddress: String,
        balance: Double,
        fee: Web3NetworkFee,
        password: String,
        salt: String,
        onCompletion: @escaping (Result<Bool, Error>) -> Void
    )
}

final class DefaultConfirmationInteractor {
    
}

extension DefaultConfirmationInteractor: ConfirmationInteractor {
    
    func send(
        tokenFrom: Web3Token,
        toAddress: String,
        balance: Double,
        fee: Web3NetworkFee,
        password: String,
        salt: String,
        onCompletion: @escaping (Result<Bool, Error>) -> Void
    ) {
     
        // TODO: @Annon to fill up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            onCompletion(.success(true))
        }
    }
}
