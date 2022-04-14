// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct KeyStoreViewModel {
    let isEmpty: Bool
    let state: State
    let items: [KeyStoreItem]
    let selectedIdx: Int?
    let buttons: ButtonSheetViewModel
    let targetView: TransitionTargetView
}

// MARK - State

extension KeyStoreViewModel {

    enum State {
        case loading
        case loaded
        case error(error: KeyStoreViewModel.Error)
    }
}

extension KeyStoreViewModel {

    struct KeyStoreItem {
        let title: String
    }
}

// MARK: - Error

extension KeyStoreViewModel {

    struct Error {
        let title: String
        let body: String
        let actions: [String]
    }
}

// MARK: - TransitionTargetView

extension KeyStoreViewModel {

    enum TransitionTargetView {
        case keyStoreItemAt(idx: Int)
        case buttonAt(idx: Int)
        case none
    }
}