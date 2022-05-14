// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol MnemonicConfirmationWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController
    ) -> MnemonicConfirmationWireframe
}

final class DefaultMnemonicConfirmationWireframeFactory {
    
    private let accountService: AccountService
    
    init(
        accountService: AccountService
    ) {
        
        self.accountService = accountService
    }
}

extension DefaultMnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory {
    
    func makeWireframe(_ parent: UIViewController) -> MnemonicConfirmationWireframe {
        
        let service = DefaultMnemonicConfirmationService(
            accountService: accountService
        )
        
        return DefaultMnemonicConfirmationWireframe(
            parent: parent,
            service: service
        )
    }
}
