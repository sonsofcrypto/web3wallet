// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NFTsCollectionPresenterEvent {

    case dismiss
    case nftDetail(identifier: String)
}

protocol NFTsCollectionPresenter {

    func present()
    func handle(_ event: NFTsCollectionPresenterEvent)
}

final class DefaultNFTsCollectionPresenter {

    private let context: NFTsCollectionWireframeContext
    private weak var view: NFTsCollectionView!
    private let interactor: NFTsCollectionInteractor
    private let wireframe: NFTsCollectionWireframe
    
    private var latestNFTCollection: NFTCollection?
    private var latestNFTs: [NFTItem]?

    init(
        context: NFTsCollectionWireframeContext,
        view: NFTsCollectionView,
        interactor: NFTsCollectionInteractor,
        wireframe: NFTsCollectionWireframe
    ) {
        self.context = context
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultNFTsCollectionPresenter: NFTsCollectionPresenter {

    func present() {
        
        interactor.fetchCollection(with: context.nftCollectionIdentifier) { [weak self] result in
            guard let self = self else { return }
            self.handleNFTCollectionResponse(with: result)
        }
        interactor.fetchNFTs(forCollection: context.nftCollectionIdentifier) { [weak self] result in
            guard let self = self else { return }
            self.handleNFTsResponse(with: result)
        }
    }

    func handle(_ event: NFTsCollectionPresenterEvent) {

        switch event {
            
        case .dismiss:
            
            wireframe.navigate(to: .dismiss)
        
        case let .nftDetail(identifier):
            
            wireframe.navigate(to: .nftDetail(identifier: identifier))
        }
    }
}

private extension DefaultNFTsCollectionPresenter {
    
    func handleNFTCollectionResponse(
        with result: Result<NFTCollection, Error>
    ) {
        
        switch result {
            
        case let .success(collection):
            
            latestNFTCollection = collection
            refreshView()
            
        case .failure:
            // We will handle failures in the future when connecting for real,
            // right now all data will be mocked and we know it won't return any errors.
            break
        }
    }
    
    func handleNFTsResponse(
        with result: Result<[NFTItem], Error>
    ) {
        
        switch result {
            
        case let .success(nfts):
            
            latestNFTs = nfts
            refreshView()
            
        case .failure:
            // We will handle failures in the future when connecting for real,
            // right now all data will be mocked and we know it won't return any errors.
            break
        }
    }
    
    func refreshView() {
        
        guard
            let latestNFTCollection = latestNFTCollection,
            let latestNFTs = latestNFTs
        else { return }
        view.update(
            with: .loaded(
                collection: latestNFTCollection,
                nfts: latestNFTs
            )
        )
    }
}
