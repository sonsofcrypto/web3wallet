// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum KeyStorePresenterEvent {
    case didSelectKeyStoreItemtAt(idx: Int)
    case didSelectAccessory(idx: Int)
    case didSelectErrorActionAt(idx: Int)
    case didSelectButtonAt(idx: Int)
    case didChangeButtonsSheetMode(sheetMode: ButtonSheetViewModel.SheetMode)
}

protocol KeyStorePresenter: AnyObject {
    func present()
    func handle(_ event: KeyStorePresenterEvent)
}

final class DefaultKeyStorePresenter {
    private weak var view: KeyStoreView?
    private let wireframe: KeyStoreWireframe
    private let interactor: KeyStoreInteractor
    private let settingsService: SettingsService

    private var targetView: KeyStoreViewModel.TransitionTargetView = .none
    private var buttonsViewModel: ButtonSheetViewModel = .init(
        buttons: ButtonSheetViewModel.compactButtons(),
        sheetMode: .compact
    )

    init(
        view: KeyStoreView,
        wireframe: KeyStoreWireframe,
        interactor: KeyStoreInteractor,
        settingsService: SettingsService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.settingsService = settingsService
    }

    func updateView() {
        view?.update(with: viewModel())
    }
}

extension DefaultKeyStorePresenter: KeyStorePresenter {

    func present() {
        updateView()
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
        case let .didChangeButtonsSheetMode(mode):
            handleDidChangeButtonsState(mode)
        }
    }
}

private extension DefaultKeyStorePresenter {

    func handleDidSelectItem(at idx: Int) {
        let keyStoreItem = interactor.items[idx]
        interactor.selected = keyStoreItem
        view?.update(with: viewModel())
        wireframe.navigate(to: .networks)
    }

    func handleDidSelectAccessory(at idx: Int) {
        targetView = .keyStoreItemAt(idx: idx)
        view?.updateTargetView(targetView)
        let item = interactor.items[idx]
        wireframe.navigate(
            to: .keyStoreItem(
                item: item,
                handler: { [weak self] item in
                    self?.handleDidUpdateNewKeyStoreItem(item)
                },
                onDeleted: { [weak self] in
                    guard let self = self else { return }
                    if self.interactor.items.isEmpty {
                        self.wireframe.navigate(to: .hideNetworksAndDashboard)
                    }
                    self.present()
                }
            )
        )
    }

    func handleDidSelectErrorAction(at idx: Int) {
        view?.update(with: viewModel())
    }

    func handleButtonAction(at idx: Int) {
        targetView = .buttonAt(idx: idx)
        view?.updateTargetView(targetView)
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
            handleDidChangeButtonsState(.expanded)
        case .connectHardwareWallet:
            wireframe.navigate(to: .connectHardwareWaller)
        case .importPrivateKey:
            wireframe.navigate(to: .importPrivateKey)
        case .createMultiSig:
            wireframe.navigate(to: .createMultisig)
        }
    }

    func handleDidChangeButtonsState(_ sheetMode: ButtonSheetViewModel.SheetMode) {
        guard buttonsViewModel.sheetMode != sheetMode else { return }
        buttonsViewModel = .init(
            buttons: sheetMode.isCompact()
                ? ButtonSheetViewModel.compactButtons()
                : ButtonSheetViewModel.expandedButtons(),
            sheetMode: sheetMode
        )
        updateView()
    }

    func handleDidCreateNewKeyStoreItem(_ keyStoreItem: KeyStoreItem) {
        interactor.selected = keyStoreItem
        if let idx = interactor.items.firstIndex(of: keyStoreItem) {
            targetView = .keyStoreItemAt(idx: idx)
        }
        updateView()
        if interactor.items.count == 1 {
            // HACK: This is non ideal, but since we dont have `viewDidAppear`
            // simply animate to dashboard after first wallet was created
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                 self?.wireframe.navigate(to: .dashBoardOnboarding)
            }
        }
        targetView = .none
    }

    func handleDidUpdateNewKeyStoreItem(_ keyStoreItem: KeyStoreItem) {
        if let idx = interactor.items.firstIndex(of: keyStoreItem) {
            targetView = .keyStoreItemAt(idx: idx)
        }
        view?.update(with: viewModel())
    }
}

private extension DefaultKeyStorePresenter {

    func viewModel(_ state: KeyStoreViewModel.State = .loaded) -> KeyStoreViewModel {
        .init(
            isEmpty: interactor.items.isEmpty,
            state: state,
            items: interactor.items.map {
                KeyStoreViewModel.KeyStoreItem(
                    title: $0.name,
                    address: $0.addressFormatted
                )
            },
            selectedIdxs: [
                selectedIdxs()
            ].compactMap{ $0 },
            buttons: buttonsViewModel,
            targetView: targetView,
            transitionStyle: ServiceDirectory.transitionStyle
        )
    }
    
    func selectedIdxs() -> Int? {
        if let index = interactor.items.firstIndex(of: interactor.selected) { return index }
        // If we have items and the keystore item could not tell us which one is selected
        // we default to 0, this should not happen though!
        guard interactor.items.count > 0 else { return nil }
        return 0
    }

    func viewModel(from error: Error) -> KeyStoreViewModel {
        viewModel(
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

private extension Array where Element == KeyStoreItem {
    
    func firstIndex(of keyStoreItem: KeyStoreItem?) -> Int? {
        firstIndex(where: { $0.uuid == keyStoreItem?.uuid })
    }
}

private extension KeyStoreItem {
    var addressFormatted: String? {
        guard let address = addresses[derivationPath] else { return nil }
        return Formatter.address.string(
            address,
            digits: 10,
            for: .ethereum()
        )
    }
}
