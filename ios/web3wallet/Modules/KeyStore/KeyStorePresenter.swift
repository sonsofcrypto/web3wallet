// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum KeyStorePresenterEvent {
    case didSelectKeyStoreItemtAt(idx: Int)
    case didSelectAccessory(idx: Int)
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

    private var targetView: KeyStoreViewModel.TransitionTargetView = .none
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
    }

    func updateView() {
        view?.update(with: viewModel())
    }
}

// MARK: WalletsPresenter

extension DefaultKeyStorePresenter: KeyStorePresenter {

    func present() {
        view?.update(with: viewModel(.loading))
        interactor.load { [weak self] items in
            DispatchQueue.main.async {
                self?.updateView()
            }
        }
    }

    func handle(_ event: KeyStorePresenterEvent) {
        switch event {
        case let .didSelectKeyStoreItemtAt(idx):
            handleDidSelectItem(at: idx)
        case let .didSelectAccessory(idx):
            handleDidSelectAccessory(at: idx)
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
        let keyStoreItem = interactor.keyStoreItems[idx]
        interactor.selectedKeyStoreItem = keyStoreItem
        view?.update(with: viewModel())
        wireframe.navigate(to: .networks)
    }

    func handleDidSelectAccessory(at idx: Int) {
        targetView = .buttonAt(idx: idx)
        let item = interactor.keyStoreItems[idx]
        wireframe.navigate(to: .keyStoreItem(item: item) { [weak self] item in
            self?.handleDidUpdateNewKeyStoreItem(item)
        })
    }

    func handleDidSelectErrorAction(at idx: Int) {
        view?.update(with: viewModel())
    }

    func handleButtonAction(at idx: Int) {
        targetView = .buttonAt(idx: idx)

        switch buttonsViewModel.buttons[idx].type {
        case .newMnemonic:
            wireframe.navigate(to: .newMnemonic { [weak self] keyStoreItem in
                self?.handleDidCreateNewKeyStoreItem(keyStoreItem)
            })
        case .importMnemonic:
            wireframe.navigate(to: .importMnemonic { [weak self] item in
                self?.handleDidCreateNewKeyStoreItem(item)
            })
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
        guard buttonsViewModel.isExpanded != open else {
            return
        }

        buttonsViewModel = .init(
            buttons: open
                ? ButtonSheetViewModel.expandedButtons()
                : ButtonSheetViewModel.compactButtons()
            ,
            isExpanded: open
        )
        view?.update(with: viewModel())
    }

    func handleDidCreateNewKeyStoreItem(_ keyStoreItem: KeyStoreItem) {
        interactor.selectedKeyStoreItem = keyStoreItem
        if let idx = interactor.index(of: keyStoreItem) {
            targetView = .keyStoreItemAt(idx: idx)
        }
        view?.update(with: viewModel())
        // Start target view for dismiss when navigating to create / import / edit
        // Handle animation type based on settings store
        // Handle animating logo to 0 in viewController only based on current value
        if interactor.keyStoreItems.count == 1 {
            handleFirstSeedCreation(keyStoreItem)
        }
        targetView = .none
    }

    func handleDidUpdateNewKeyStoreItem(_ keyStoreItem: KeyStoreItem) {
        if let idx = interactor.index(of: keyStoreItem) {
            targetView = .keyStoreItemAt(idx: idx)
        }
        view?.update(with: viewModel())
    }

    func handleFirstSeedCreation(_ keyStoreItem: KeyStoreItem) {

    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultKeyStorePresenter {

    func viewModel(_ state: KeyStoreViewModel.State = .loaded) -> KeyStoreViewModel {
        let active = interactor.selectedKeyStoreItem
        return .init(
            isEmpty: interactor.isEmpty(),
            state: state,
            items: interactor.keyStoreItems.map {
                KeyStoreViewModel.KeyStoreItem(title: $0.name)
            },
            selectedIdx: interactor.keyStoreItems.firstIndex(
                where: { $0.uuid == active?.uuid }
            ),
            buttons: buttonsViewModel,
            targetView: .none
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
