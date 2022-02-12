// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum WalletsPresenterEvent {
    case didSelectWalletAt(idx: Int)
    case didSelectErrorActionAt(idx: Int)
    case createNewWallet
    case importWallet
    case connectHardwareWallet
}

protocol WalletsPresenter {

    func present()
    func handle(_ event: WalletsPresenterEvent)
}

// MARK: - DefaultWalletsPresenter

class DefaultWalletsPresenter {

    private let interactor: WalletsInteractor
    private let wireframe: WalletsWireframe

    private var latestWallets: [Wallet]

    private weak var view: WalletsView?

    init(
        view: WalletsView,
        interactor: WalletsInteractor,
        wireframe: WalletsWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.latestWallets = []
    }
}

// MARK: WalletsPresenter

extension DefaultWalletsPresenter: WalletsPresenter {

    func present() {
        view?.update(with: .loading)
        interactor.loadWallets { [weak self] wallets in
            self?.latestWallets = wallets
            self?.view?.update(
                with: viewModel(from: wallets, active: interactor.activeWallet)
            )
        }
    }

    func handle(_ event: WalletsPresenterEvent) {
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

private extension DefaultWalletsPresenter {

    func handleDidSelectWallet(at idx: Int) {
        let wallet = latestWallets[idx]
        interactor.activeWallet = wallet
        view?.update(with: viewModel(from: latestWallets, active: wallet))
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
            view?.update(with: viewModel(from: error))
        }
    }

    func handleConnectHardwareWallet() {
        // TODO: Implement
        print("handleConnectHardwareWallet")
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultWalletsPresenter {

    func viewModel(from wallets: [Wallet], active: Wallet?) -> WalletsViewModel {
        .loaded(
            wallets: viewModel(from: wallets),
            selectedIdx: selectedIdx(wallets, active: active)
        )
    }

    func viewModel(from wallets: [Wallet]) -> [WalletsViewModel.Wallet] {
        wallets.map {
            .init(title: $0.name)
        }
    }

    func viewModel(from error: Error) -> WalletsViewModel {
        .error(
            error: WalletsViewModel.Error(
                title: "Error",
                body: error.localizedDescription,
                actions: [Localized("OK")]
            )
        )
    }

    func selectedIdx(_ wallets: [Wallet], active: Wallet?) -> Int {
        guard let wallet = active else {
            return 0
        }

        return wallets.firstIndex{ $0.id == wallet.id} ?? 0
    }
}
