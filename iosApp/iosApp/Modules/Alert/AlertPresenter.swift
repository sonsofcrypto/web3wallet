// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UniformTypeIdentifiers

enum AlertPresenterEvent {
    case dismiss
}

protocol AlertPresenter: AnyObject {
    func present()
    func handle(_ event: AlertPresenterEvent)
}

final class DefaultAlertPresenter {
    private let context: AlertContext
    private weak var view: AlertView!
    private let wireframe: AlertWireframe

    init(
        context: AlertContext,
        view: AlertView,
        wireframe: AlertWireframe
    ) {
        self.context = context
        self.view = view
        self.wireframe = wireframe
    }
}

extension DefaultAlertPresenter: AlertPresenter {

    func present() {
        let viewModel = AlertViewModel(context: context)
        view.update(with: viewModel)
    }

    func handle(_ event: AlertPresenterEvent) {
        switch event {
        case .dismiss:
            wireframe.navigate(to: .dismiss)
        }
    }
}
