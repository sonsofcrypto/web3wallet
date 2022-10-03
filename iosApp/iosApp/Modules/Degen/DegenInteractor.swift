// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol DegenInteractorLister: AnyObject {
    func handle(networkEvent event: NetworksEvent)
}

protocol DegenInteractor: AnyObject {
    var categoriesActive: [DAppCategory] { get }
    var categoriesInactive: [DAppCategory] { get }
    func addListener(_ listener: DegenInteractorLister)
    func removeListener(_ listener: DegenInteractorLister)
}

final class DefaultDegenInteractor {
    private let degenService: DegenService
    private let networksService: NetworksService
    
    private var listeners: [WeakContainer] = []

    init(
        _ degenService: DegenService,
        networksService: NetworksService
    ) {
        self.degenService = degenService
        self.networksService = networksService
    }
    
    deinit {
        print("[DEBUG][Interactor] deinit \(String(describing: self))")
    }
}

extension DefaultDegenInteractor: DegenInteractor {

    var categoriesActive: [DAppCategory] {
        degenService.categoriesActive
    }

    var categoriesInactive: [DAppCategory] {
        degenService.categoriesInactive
    }
    
    func addListener(_ listener: DegenInteractorLister) {
        listeners = [WeakContainer(listener)]
        networksService.add(listener__: self)
    }

    func removeListener(_ listener: DegenInteractorLister) {
        listeners = []
        networksService.remove(listener__: self)
    }
}

extension DefaultDegenInteractor: NetworksListener {

    func handle(event_: NetworksEvent) {
        emit(event_)
    }
}

private extension DefaultDegenInteractor {
    
    func emit(_ event: NetworksEvent) {
        listeners.forEach { $0.value?.handle(networkEvent: event) }
    }

    class WeakContainer {
        weak var value: DegenInteractorLister?

        init(_ value: DegenInteractorLister) {
            self.value = value
        }
    }
}
