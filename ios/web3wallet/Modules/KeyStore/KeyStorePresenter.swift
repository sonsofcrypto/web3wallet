// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum KeyStorePresenterEvent {
    case didSelectKeyStoreItemtAt(idx: Int)
    case didSelectErrorActionAt(idx: Int)
    case didSelectButtonAt(idx: Int)
    case didChangeButtonsState(open: Bool)
}

protocol KeyStorePresenter {

    func present()
    func handle(_ event: KeyStorePresenterEvent)
}

// MARK: - DefaultKeyStorePresenter

class DefaultKeyStorePresenter {

    private let interactor: KeyStoreInteractor
    private let wireframe: KeyStoreWireframe

    private var latestItems: [KeyStoreItem]
    private var buttonsViewModel: ButtonSheetViewModel = .init(
        buttons: ButtonSheetViewModel.compactButtons(),
        isExpanded: false
    )

    private weak var view: KeyStoreView?

    init(
        view: KeyStoreView,
        interactor: KeyStoreInteractor,
        wireframe: KeyStoreWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.latestItems = []
    }
}

// MARK: WalletsPresenter

extension DefaultKeyStorePresenter: KeyStorePresenter {

    func present() {
        view?.update(with: viewModel(.loading))
        interactor.loadWallets { [weak self] wallets in
            self?.latestItems = wallets
            self?.view?.update(
                with: viewModel()
            )
        }
    }

    func handle(_ event: KeyStorePresenterEvent) {
        switch event {
        case let .didSelectKeyStoreItemtAt(idx):
            handleDidSelectItem(at: idx)
        case let .didSelectErrorActionAt(idx: idx):
            handleDidSelectErrorAction(at: idx)
        case let .didSelectButtonAt(idx):
            handleButtonAction(at: idx)
        case let .didChangeButtonsState(open):
            handleDidChangeButtonsState(open)
        }
    }
}

// MARK: - Event handling

private extension DefaultKeyStorePresenter {

    func handleDidSelectItem(at idx: Int) {
        let wallet = latestItems[idx]
        interactor.activeKeyStoreItem = wallet
        view?.update(with: viewModel())
        wireframe.navigate(to: .networks)
    }

    func handleDidSelectErrorAction(at idx: Int) {
        view?.update(with: viewModel())
    }

    func handleButtonAction(at idx: Int) {
        switch buttonsViewModel.buttons[idx].type {
        case .newMnemonic:
            wireframe.navigate(to: .newMnemonic)
        case .importMnemonic:
            wireframe.navigate(to: .newMnemonic)
        case .moreOption:
            handleDidChangeButtonsState(true)
        case .connectHardwareWallet:
            wireframe.navigate(to: .connectHardwareWaller)
        case .importPrivateKey:
            wireframe.navigate(to: .importPrivateKey)
        case .createMultiSig:
            wireframe.navigate(to: .createMultisig)
        }
    }

    func handleDidChangeButtonsState(_ open: Bool) {
        buttonsViewModel = .init(
            buttons: open
                ? ButtonSheetViewModel.expandedButtons()
                : ButtonSheetViewModel.compactButtons()
            ,
            isExpanded: open
        )
        view?.update(with: viewModel())
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultKeyStorePresenter {

    func viewModel(_ state: KeyStoreViewModel.State = .loaded) -> KeyStoreViewModel {
        let active = interactor.activeKeyStoreItem
        return .init(
            isEmpty: interactor.isEmpty,
            state: state,
            items: latestItems.map { KeyStoreViewModel.KeyStoreItem(title: $0.name) },
            selectedIdx: latestItems.firstIndex(where: { $0.uuid == active?.uuid }),
            buttons: buttonsViewModel
        )
    }

    func viewModel(from error: Error) -> KeyStoreViewModel {
        return viewModel(
            .error(
                error: KeyStoreViewModel.Error(
                    title: "Error",
                    body: error.localizedDescription,
                    actions: [Localized("OK")]
                )
            )
        )
    }
}
