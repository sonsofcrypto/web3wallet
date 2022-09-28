// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

class MyAlertViewController {

    private var action: [Action]
    private weak var handler: ((Idx)->())?

    init(viewModel: AlertViewModel) {
        // present(AlertController(viewModel: AlertViewModel, handler: (Idx) -> ()))
    }
}

enum ImageViewModel {
    case name(name: String)
    case gif(name: String)
    case url(url: URL)
}

// Shared viewModels
struct AlertViewModel {
    let title: String
    let image: ImageViewModel?
    let description: String
    let actions: [Action]

    enum Action {
        case cancel(title: String)
        case destructive(title: String)
        case `default`(title: String)
    }
}

struct SimpleViewModel {
    let props: String
    let alert: AlertViewModel?
}

enum TemplatePresenterEvent {
    case didSelectWallet(idx: Int)
    case didSelectItem(idx: Int)
    case didSelectAccessoryAction(idx: Int)
    case didSelectAlertEventAt(idx: Int)
    case another
}

protocol TemplatePresenter {
    func present()
    func handle(_ event: TemplatePresenterEvent)
}

// MARK: - DefaultTemplatePresenter

class DefaultTemplatePresenter {
    private weak var view: TemplateView?
    private let wireframe: TemplateWireframe
    private let interactor: TemplateInteractor

    private var error: Error

    init(
        _ view: TemplateView,
        wireframe: TemplateWireframe,
        interactor: TemplateInteractor
        // Context
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
    }
}

// MARK: - TemplatePresenter

extension DefaultTemplatePresenter: TemplatePresenter {

    func present() {
        updateView()
    }

    func handle(_ event: TemplatePresenterEvent) {
        switch event {
        case let .didSelectItem(idx):
            handle(event)
        case .another:
            ()
        case let .didSelectAlertEventAt(idx):
            error = nil
            // Handle user decision
        }
    }

}

// MARK: - Event handling

private extension DefaultTemplatePresenter {

    func handleEventBlaBla() {

    }
}

// MARK: - ViewModel

private extension DefaultTemplatePresenter {

    func updateView() {
        view?.update(with: viewModel())
    }

    func viewModel() -> TemplateViewModel {
        TemplateViewModel.loaded(
            items: [.init(title: "")],
            selectedIdx: 0
        )
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultTemplatePresenter {

//    func viewModel(from items: [Item], active: Item?) -> TemplateViewModel {
//        .loaded(
//            wallets: viewModel(from: wallets),
//            selectedIdx: selectedIdx(wallets, active: active)
//        )
//    }

    func action(idx: Int) ->
}
