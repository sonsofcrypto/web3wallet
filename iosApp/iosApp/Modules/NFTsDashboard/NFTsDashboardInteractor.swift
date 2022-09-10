// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol NFTsDashboardInteractorLister: AnyObject {
    func popToRootAndRefresh()
}

protocol NFTsDashboardInteractor: AnyObject {

    func fetchYourNFTs(
        isPullDownToRefreh: Bool,
        onCompletion: @escaping (Result<[NFTItem], Error>) -> Void
    )
    func fetchYourNFTsCollections(
        onCompletion: (Result<[NFTCollection], Error>) -> Void
    )
    func addListener(_ listener: NFTsDashboardInteractorLister)
    func removeListener(_ listener: NFTsDashboardInteractorLister)
}

final class DefaultNFTsDashboardInteractor {

    private let networksService: NetworksService
    private let service: NFTsService
    
    private var listener: WeakContainer?

    init(
        networksService: NetworksService,
        service: NFTsService
    ) {
        self.networksService = networksService
        self.service = service
    }
}

extension DefaultNFTsDashboardInteractor: NFTsDashboardInteractor {
    
    func fetchYourNFTs(
        isPullDownToRefreh: Bool,
        onCompletion: @escaping (Result<[NFTItem], Error>) -> Void
    ) {
        guard !isPullDownToRefreh else {
            service.fetchNFTs(onCompletion: onCompletion)
            return
        }
        guard service.yourNFTs().isEmpty else {
            onCompletion(.success(service.yourNFTs()))
            return
        }
        service.fetchNFTs(onCompletion: onCompletion)
    }
    
    func fetchYourNFTsCollections(onCompletion: (Result<[NFTCollection], Error>) -> Void) {
        service.yourNftCollections(onCompletion: onCompletion)
    }
}

extension DefaultNFTsDashboardInteractor: NetworksListener {

    func addListener(_ listener: NFTsDashboardInteractorLister) {
        self.listener = WeakContainer(listener)
        networksService.add(listener__: self)
    }

    func removeListener(_ listener: NFTsDashboardInteractorLister) {
        self.listener = nil
        networksService.remove(listener__: self)
    }

    func handle(event_ event: NetworksEvent) {
        guard event is NetworksEvent.NetworkDidChange else { return }
        listener?.value?.popToRootAndRefresh()
    }

    private class WeakContainer {
        weak var value: NFTsDashboardInteractorLister?
        init(_ value: NFTsDashboardInteractorLister) {
            self.value = value
        }
    }
}
