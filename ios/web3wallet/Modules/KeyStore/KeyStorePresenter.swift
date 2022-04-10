// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum KeyStorePresenterEvent {
    case didSelectWalletAt(idx: Int)
    case didSelectErrorActionAt(idx: Int)
    case createNewWallet
    case importWallet
    case connectHardwareWallet
}

protocol KeyStorePresenter {

    func present()
    func handle(_ event: KeyStorePresenterEvent)
}

// MARK: - DefaultKeyStorePresenter

class DefaultKeyStorePresenter {

    private let interactor: KeyStoreInteractor
    private let wireframe: KeyStoreWireframe

    private var latestWallets: [KeyStoreItem]

    private weak var view: KeyStoreView?

    init(
        view: KeyStoreView,
        interactor: KeyStoreInteractor,
        wireframe: KeyStoreWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.latestWallets = []
    }
}

// MARK: WalletsPresenter

extension DefaultKeyStorePresenter: KeyStorePresenter {

    func present() {
        view?.update(with: .loading)
        interactor.loadWallets { [weak self] wallets in
            self?.latestWallets = wallets
            self?.view?.update(
                with: viewModel(from: wallets, active: interactor.activeWallet)
            )
        }
    }

    func handle(_ event: KeyStorePresenterEvent) {
        switch event {
        case let .didSelectWalletAt(idx):
            handleDidSelectWallet(at: idx)
        case let .didSelectErrorActionAt(idx: idx):
            handleDidSelectErrorAction(at: idx)
        case .createNewWallet:
            handleCreateNewWallet()
        case .importWallet:
            handleImportWallet()
        case .connectHardwareWallet:
            handleConnectHardwareWallet()
        }
    }
}

// MARK: - Event handling

private extension DefaultKeyStorePresenter {

    func handleDidSelectWallet(at idx: Int) {
        let wallet = latestWallets[idx]
        interactor.activeWallet = wallet
        view?.update(with: viewModel(from: latestWallets, active: wallet))
        wireframe.navigate(to: .networks)
    }

    func handleDidSelectErrorAction(at idx: Int) {
        let active = interactor.activeWallet
        view?.update(with: viewModel(from: latestWallets, active: active))
    }

    func handleCreateNewWallet() {
        do {
            let wallet = try interactor.createNewWallet("1111", passphrase: nil)
            latestWallets.append(wallet)
            interactor.activeWallet = wallet
            view?.update(with: viewModel(from: latestWallets, active: wallet))
        } catch {
            print(error)
            view?.update(with: viewModel(from: error))
        }
    }

    func handleImportWallet() {
        do {
            let wallet = try interactor.importWallet(
                "some menemonic",
                password: "1111",
                passphrase: nil
            )
            latestWallets.append(wallet)
            interactor.activeWallet = wallet
            view?.update(with: viewModel(from: latestWallets, active: wallet))
        } catch {
            print(error)
            view?.update(with: viewModel(from: error))
        }
    }

    func handleConnectHardwareWallet() {
        // TODO: Implement
        print("handleConnectHardwareWallet")
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultKeyStorePresenter {

    func viewModel(from wallets: [KeyStoreItem], active: KeyStoreItem?) -> KeyStoreViewModel {
        .loaded(
            wallets: viewModel(from: wallets),
            selectedIdx: selectedIdx(wallets, active: active)
        )
    }

    func viewModel(from wallets: [KeyStoreItem]) -> [KeyStoreViewModel.Wallet] {
        wallets.map {
            .init(title: $0.name)
        }
    }

    func viewModel(from error: Error) -> KeyStoreViewModel {
        .error(
            error: KeyStoreViewModel.Error(
                title: "Error",
                body: error.localizedDescription,
                actions: [Localized("OK")]
            )
        )
    }

    func selectedIdx(_ wallets: [KeyStoreItem], active: KeyStoreItem?) -> Int {
        guard let wallet = active else {
            return 0
        }

        return wallets.firstIndex{ $0.uuid == wallet.uuid } ?? 0
    }
}
