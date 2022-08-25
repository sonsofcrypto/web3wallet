// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NFTsDashboardPresenterEvent {
    case viewCollectionNFTs(collectionId: String)
    case viewNFT(identifier: String)
}

protocol NFTsDashboardPresenter {

    func present(isPullDownToRefreh: Bool)
    func handle(_ event: NFTsDashboardPresenterEvent)
    func releaseResources()
}

final class DefaultNFTsDashboardPresenter {

    private weak var view: NFTsDashboardView!
    private let interactor: NFTsDashboardInteractor
    private let wireframe: NFTsDashboardWireframe
    private let nftsService: NFTsService
    
    private var latestNFTs: [NFTItem]?
    private var latestCollections: [NFTCollection]?

    init(
        view: NFTsDashboardView,
        interactor: NFTsDashboardInteractor,
        wireframe: NFTsDashboardWireframe,
        nftsService: NFTsService
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.nftsService = nftsService
        
        nftsService.addListener(self)
        interactor.addListener(self)
    }
    
    deinit {
        print("[DEBUG][Presenter] deinit \(String(describing: self))")
        interactor.removeListener(self)
    }
}

extension DefaultNFTsDashboardPresenter: NFTsDashboardPresenter {

    func present(isPullDownToRefreh: Bool) {
        
        view.update(with: .loading)
        
        interactor.fetchYourNFTs(isPullDownToRefreh: isPullDownToRefreh) { [weak self] result in
            
            guard let self = self else { return }
            
            self.handleYourNFTsResponse(with: result)
        }
    }

    func handle(_ event: NFTsDashboardPresenterEvent) {

        switch event {
            
        case let .viewCollectionNFTs(collectionId):
            
            wireframe.navigate(to: .viewCollectionNFTs(collectionId: collectionId))
        
        case let .viewNFT(identifier):
            
            guard let latestNFTs = latestNFTs else { return }
            let nftItem = latestNFTs.filter { $0.identifier == identifier }.first
            guard let nftItem = nftItem else { return }
            wireframe.navigate(to: .viewNFT(nftItem: nftItem))
        }
    }
    
    func releaseResources() {
        
        nftsService.removeListener(self)
    }
}

private extension DefaultNFTsDashboardPresenter {
    
    func handleYourNFTsResponse(
        with result: Result<[NFTItem], Error>
    ) {
        
        switch result {
            
        case let .success(nfts):
            
            latestNFTs = nfts
            fetchNFTsCollections()
            
        case .failure:
            // We will handle failures in the future when connecting for real,
            // right now all data will be mocked and we know it won't return any errors.
            break
        }
    }
    
    func fetchNFTsCollections() {
        
        interactor.fetchYourNFTsCollections { [weak self] result in
            
            guard let self = self else { return }
            
            self.handleCollectionsResponse(with: result)
        }
    }
    
    func handleCollectionsResponse(
        with result: Result<[NFTCollection], Error>
    ) {
        
        switch result {
            
        case let .success(collections):
            
            latestCollections = collections
            refreshView()
            
        case .failure:
            // We will handle failures in the future when connecting for real,
            // right now all data will be mocked and we know it won't return any errors.
            break
        }
    }
    
    func refreshView() {
        
        guard
            let latestNFTs = latestNFTs,
            let latestCollections = latestCollections
        else {
            return
        }
        
        let nfts: [NFTsDashboardViewModel.NFT] = latestNFTs.compactMap {

            NFTsDashboardViewModel.NFT(
                identifier: $0.identifier,
                image: $0.image
            )
        }
        
        let collections: [NFTsDashboardViewModel.Collection] = latestCollections.compactMap {
            
            NFTsDashboardViewModel.Collection(
                identifier: $0.identifier,
                coverImage: $0.coverImage,
                title: $0.title,
                author: $0.author
            )
        }
        
        
        view.update(
            with: .loaded(nfts: nfts, collections: collections)
        )
    }
}

extension DefaultNFTsDashboardPresenter: NFTsServiceListener {
    
    func nftsChanged() {
        // Here we call to force a refresh in the view
        present(isPullDownToRefreh: true)
    }
}

extension DefaultNFTsDashboardPresenter: NFTsDashboardInteractorLister {
    
    func popToRootAndRefresh() {
        // Here we call to force a refresh in the view
        view.popToRootAndRefresh()
    }
}
