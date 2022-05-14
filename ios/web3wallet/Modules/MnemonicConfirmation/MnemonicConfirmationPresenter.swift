// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UniformTypeIdentifiers

enum MnemonicConfirmationPresenterEvent {
    
    case mnemonicChanged(to: String)
    case confirm
}

protocol MnemonicConfirmationPresenter: AnyObject {

    func present()
    func handle(_ event: MnemonicConfirmationPresenterEvent)
}

final class DefaultMnemonicConfirmationPresenter {

    private let view: MnemonicConfirmationView
    private let wireframe: MnemonicConfirmationWireframe
    private let service: MnemonicConfirmationService

    init(
        view: MnemonicConfirmationView,
        wireframe: MnemonicConfirmationWireframe,
        service: MnemonicConfirmationService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.service = service
    }
}

extension DefaultMnemonicConfirmationPresenter: MnemonicConfirmationPresenter {

    func present() {
        
        let viewModel = makeViewModel(for: "")
        view.update(with: viewModel)
    }

    func handle(_ event: MnemonicConfirmationPresenterEvent) {
        
        switch event {
            
        case let .mnemonicChanged(mnemonic):
            
            let viewModel = makeViewModel(for: mnemonic)
            view.update(with: viewModel)

        case .confirm:
            
            wireframe.navigate(to: .dismiss)
        }
    }
}

private extension DefaultMnemonicConfirmationPresenter {
    
    func makeViewModel(for mnemonic: String) -> MnemonicConfirmationViewModel {
        
        let invalidWords = service.findInvalidWords(in: mnemonic)
        let isMnemonicValid = service.isMnemonicValid(mnemonic)
        
        return .init(
            invalidWords: invalidWords,
            isValid: isMnemonicValid
        )
    }
}
