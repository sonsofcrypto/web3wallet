// Created by web3d4v on 24/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NFTsDashboardPresenterEvent {

}

protocol NFTsDashboardPresenter {

    func present()
    func handle(_ event: NFTsDashboardPresenterEvent)
}

final class DefaultNFTsDashboardPresenter {

    private weak var view: NFTsDashboardView!
    private let interactor: NFTsDashboardInteractor
    private let wireframe: NFTsDashboardWireframe
    
    private var latestNFTs: [NFTItem]?
    private var latestCollections: [NFTCollection]?

    init(
        view: NFTsDashboardView,
        interactor: NFTsDashboardInteractor,
        wireframe: NFTsDashboardWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension DefaultNFTsDashboardPresenter: NFTsDashboardPresenter {

    func present() {
        
        interactor.fetchYourNFTs { [weak self] result in
            
            guard let self = self else { return }
            
            self.handleYourNFTsResponse(with: result)
        }
        interactor.fetchYourNFTsCollections { [weak self] result in
            
            guard let self = self else { return }
            
            self.handleCollectionsResponse(with: result)
        }
    }

    func handle(_ event: NFTsDashboardPresenterEvent) {

    }
}

private extension DefaultNFTsDashboardPresenter {
    
    func handleYourNFTsResponse(
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
        
        let nfts: [NFTsDashboardViewModel.NFT] = latestNFTs.sorted {
            $0.ethPrice > $1.ethPrice
        }.compactMap {
            
            NFTsDashboardViewModel.NFT(
                identifier: $0.identifier,
                image: $0.image
            )
        }
        
        let collections: [NFTsDashboardViewModel.Collection] = latestCollections.sorted {
            return $0.identifier < $1.identifier
        }.compactMap {
            
            NFTsDashboardViewModel.Collection(
                coverImage: $0.coverImage,
                title: $0.title,
                author: $0.author,
                isVerifiedAccount: $0.isVerifiedAccount,
                authorImage: $0.authorImage
            )
        }
        
        
        let viewModel = NFTsDashboardViewModel(
            nfts: nfts,
            collections: collections
        )
        view.update(with: viewModel)
    }
}
