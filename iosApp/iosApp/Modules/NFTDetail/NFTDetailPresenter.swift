// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

enum NFTDetailPresenterEvent {
    case send
    case dismiss
}

protocol NFTDetailPresenter {
    func present()
    func handle(_ event: NFTDetailPresenterEvent)
}

final class DefaultNFTDetailPresenter {
    private weak var view: NFTDetailView!
    private let wireframe: NFTDetailWireframe
    private let interactor: NFTDetailInteractor
    private let context: NFTDetailWireframeContext

    private var latestNFT: NFTItem?
    private var latestNFTCollection: NFTCollection?

    init(
        view: NFTDetailView,
        wireframe: NFTDetailWireframe,
        interactor: NFTDetailInteractor,
        context: NFTDetailWireframeContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }
}

extension DefaultNFTDetailPresenter: NFTDetailPresenter {

    func present() {
        interactor.fetchNFT(with: context.nftIdentifier) { [weak self] result in
            guard let self = self else { return }
            self.handleNFTResponse(with: result)
        }
        interactor.fetchNFTCollection(with: context.nftCollectionIdentifier) { [weak self] result in
            guard let self = self else { return }
            self.handleNFTCollectionResponse(with: result)
        }
    }

    func handle(_ event: NFTDetailPresenterEvent) {
        switch event {
        case .send:
            guard let item = latestNFT else { return }
            wireframe.navigate(to: .send(item))
        case .dismiss:
            wireframe.navigate(to: .dismiss)
        }
    }
}

private extension DefaultNFTDetailPresenter {
    
    func handleNFTResponse(
        with result: Result<NFTItem, Error>
    ) {
        switch result {
        case let .success(nft):
            latestNFT = nft
            refreshView()
        case .failure:
            // We will handle failures in the future when connecting for real,
            // right now all data will be mocked and we know it won't return any errors.
            break
        }
    }
    
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
    
    func refreshView() {
        guard
            let latestNFT = latestNFT,
            let latestNFTCollection = latestNFTCollection
        else { return }
        view.update(
            with: .loaded(
                nft: latestNFT,
                collection: latestNFTCollection
            )
        )
    }
}
