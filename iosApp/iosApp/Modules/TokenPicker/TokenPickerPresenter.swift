// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum TokenPickerPresenterEvent {

    case search(searchTerm: String)
    case selectItem(TokenPickerViewModel.Token)
    case addCustomToken
    case done
    case dismiss
}

protocol TokenPickerPresenter {

    func present()
    func handle(_ event: TokenPickerPresenterEvent)
}

final class DefaultTokenPickerPresenter {

    private weak var view: TokenPickerView?
    private let interactor: TokenPickerInteractor
    private let wireframe: TokenPickerWireframe
    private let context: TokenPickerWireframeContext
    
    private var searchTerm: String = ""
    
    private var selectedTokens: [Web3Token] = []
    private var selectedTokensFiltered: [Web3Token] = []
    private var tokens = [Web3Token]()
    private var tokensFiltered = [Web3Token]()

    init(
        view: TokenPickerView,
        interactor: TokenPickerInteractor,
        wireframe: TokenPickerWireframe,
        context: TokenPickerWireframeContext
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }
}

extension DefaultTokenPickerPresenter: TokenPickerPresenter {

    func present() {

        loadSelectedTokensIfNeeded()
        refreshTokens()
        refreshData()
    }

    func handle(_ event: TokenPickerPresenterEvent) {

        switch event {
            
        case let .search(searchTerm):
            
            self.searchTerm = searchTerm
            refreshData()
                        
        case let .selectItem(token):
            
            switch context.source {
                
            case .receive:
                
                guard let token = findSelectedToken(from: token) else { return }
                wireframe.navigate(to: .tokenReceive(token))

            case .multiSelectEdit:
                
                handleTokenTappedOnMultiSelect(token: token)
                
            case let .select(onCompletion):
                
                guard let token = findSelectedToken(from: token) else { return }
                onCompletion(token)
                wireframe.dismiss()
            }
            
        case .addCustomToken:
            
            wireframe.navigate(to: .addCustomToken)
            
        case .done:
            
            guard
                case let TokenPickerWireframeContext.Source.multiSelectEdit(
                    _, _, onCompletion
                ) = context.source
            else {
                
                return
            }
            
            onCompletion(selectedTokens)
            wireframe.dismiss()
            
        case .dismiss:
            
            wireframe.dismiss()
        }
    }
}

private extension DefaultTokenPickerPresenter {
    
    func loadSelectedTokensIfNeeded() {
        
        switch context.source {
            
        case let .multiSelectEdit(_, selectedTokens, _):
            self.selectedTokens = selectedTokens
            
        default:
            selectedTokens = interactor.myTokens
        }
    }
    
    func handleTokenTappedOnMultiSelect(token: TokenPickerViewModel.Token) {
        
        if let token = selectedTokensFiltered.findToken(matching: token.tokenId) {
            
            selectedTokens = selectedTokens.removingToken(
                tokenId: token.coingGeckoId ?? ""
            )
        } else if let token = tokensFiltered.findToken(matching: token.tokenId) {
            
            selectedTokens = selectedTokens.addingToken(with: token)
        }
        
        refreshData()
    }
    
    func findSelectedToken(from token: TokenPickerViewModel.Token) -> Web3Token? {
        
        if let token = selectedTokensFiltered.findToken(matching: token.tokenId) {
            
            return token
        } else if let token = tokensFiltered.findToken(matching: token.tokenId) {
            
            return token
        } else {
            
            return nil
        }
    }
    
    func refreshTokens() {
        
        tokens = interactor.tokens(
            filteredBy: searchTerm,
            for: context.source.network
        )
    }
    
    func refreshData() {
        
        selectedTokensFiltered = selectedTokens.filterBy(searchTerm: searchTerm)
        tokensFiltered = interactor.tokens(
            filteredBy: searchTerm,
            for: context.source.network
        ).removingTokens(
            matching: selectedTokensFiltered
        )

        let sectionsToDisplay = makeSectionsToDisplay()
        updateView(with: sectionsToDisplay)
    }
    
    func updateView(
        with sectionsDisplayed: [TokenPickerViewModel.Section]
    ) {
        
        let viewModel = makeViewModel(with: sectionsDisplayed)
        view?.update(with: viewModel)
    }
    
    func makeViewModel(
        with sectionsDisplayed: [TokenPickerViewModel.Section]
    ) -> TokenPickerViewModel {
        
        .init(
            title: Localized("tokenPicker.title.\(context.source.localizedValue)"),
            allowMultiSelection: context.source.isMultiSelect,
            content: .loaded(sections: sectionsDisplayed)
        )
    }
    
    func makeSectionsToDisplay() -> [TokenPickerViewModel.Section] {
        
        var sections = [TokenPickerViewModel.Section]()
        
        if !selectedTokensFiltered.isEmpty {
            
            let groupName = Localized("tokenPicker.myTokens.title")
            sections.append(
                .init(name: groupName, items: makeMyViewModelTokens(from: selectedTokensFiltered))
            )
        }

        if !tokensFiltered.isEmpty {
            
            let groupName = Localized("tokenPicker.other.title")
            sections.append(
                .init(name: groupName, items: makeOtherViewModelTokens(from: tokensFiltered))
            )
        }

        return sections.addNoResultsIfNeeded
    }
}

private extension DefaultTokenPickerPresenter {
    
    func makeMyGroupToken(
        for prefix: String,
        tokens: [Web3Token]
    ) -> [TokenPickerViewModel.Section] {
        
        let tokens = tokens.filter { $0.name.uppercased().hasPrefix(prefix) }
        guard !tokens.isEmpty else { return [] }
        return [
            .init(name: prefix, items: makeMyViewModelTokens(from: tokens))
        ]
    }
    
    func makeMyViewModelTokens(
        from tokens: [Web3Token]
    ) -> [TokenPickerViewModel.Token] {
        
        let sortedTokens = tokens.sortByNetworkBalanceAndName
        return sortedTokens.compactMap { token in
            
            let type: TokenPickerViewModel.TokenType
            switch context.source {
                
            case .receive, .select:
                type = .init(
                    isSelected: nil,
                    balance: .init(
                        tokens: token.balance.toString(decimals: 2),
                        usdTotal: token.usdBalanceString
                    )
                )
            case .multiSelectEdit:
                let isSelected = selectedTokensFiltered.contains(
                    where: {
                        $0.network.name == token.network.name && $0.symbol == token.symbol
                    }
                )
                type = .init(
                    isSelected: isSelected,
                    balance: .init(
                        tokens: token.balance.toString(decimals: 2),
                        usdTotal: token.usdBalanceString
                    )
                )
            }
            
            let position: TokenPickerViewModel.Token.Position
            if sortedTokens.first == token && sortedTokens.last == token {
                position = .onlyOne
            } else if sortedTokens.first == token {
                position = .first
            } else if sortedTokens.last == token {
                position = .last
            } else {
                position = .middle
            }
            
            return .init(
                image: interactor.tokenIcon(for: token).pngImage ?? "default_token".assetImage!,
                symbol: token.symbol,
                name: token.name,
                network: token.network.name,
                type: type,
                position: position,
                tokenId: token.coingGeckoId ?? ""
            )
        }
    }
    
    func makeOtherGroupToken(
        for prefix: String,
        tokens: [Web3Token]
    ) -> [TokenPickerViewModel.Section] {
        
        let tokens = tokens.filter { $0.name.uppercased().hasPrefix(prefix) }
        guard !tokens.isEmpty else { return [] }
        return [
            .init(name: prefix, items: makeOtherViewModelTokens(from: tokens))
        ]
    }
    
    func makeOtherViewModelTokens(
        from tokens: [Web3Token]
    ) -> [TokenPickerViewModel.Token] {
        
        //let sortedTokens = tokens.sortByNetworkBalanceAndName
        tokens.compactMap { token in
            
            let type: TokenPickerViewModel.TokenType
            switch context.source {
                
            case .receive, .select:
                type = .init(
                    isSelected: nil,
                    balance: nil
                )
            case .multiSelectEdit:
                type = .init(
                    isSelected: false,
                    balance: nil
                )
            }
            
            let position: TokenPickerViewModel.Token.Position
            if tokens.first == token && tokens.last == token {
                position = .onlyOne
            } else if tokens.first == token {
                position = .first
            } else if tokens.last == token {
                position = .last
            } else {
                position = .middle
            }
            
            return .init(
                image: makeTokenImage(from: token),
                symbol: token.symbol,
                name: token.name,
                network: token.network.name,
                type: type,
                position: position,
                tokenId: token.coingGeckoId ?? ""
            )
        }
    }
    
    func makeTokenImage(from token: Web3Token) -> UIImage {
        
        ((token.coingGeckoId ?? "") + "_large").assetImage
        ?? "default_token".assetImage!
    }
}

private extension Array where Element == Web3Network {
    
    func hasNetwork(matching name: String) -> Bool {
        
        findNetwork(matching: name) != nil
    }
    
    func findNetwork(matching name: String) -> Web3Network? {
        
        filter { $0.name == name }.first
    }
}

private extension Array where Element == Web3Token {

    func addingToken(with token: Web3Token) -> [Web3Token] {
        
        var tokens = self
        tokens.append(token)
        return tokens
    }
    
    func removingToken(tokenId: String) -> [Web3Token] {
        
        var tokens = self
        tokens.removeAll {
            $0.coingGeckoId == tokenId
        }
        return tokens
    }
    
    func removingTokens(matching tokens: [Web3Token]) -> [Web3Token] {
        
        let ids = tokens.compactMap { $0.coingGeckoId }
        return filter {
            !ids.contains($0.coingGeckoId ?? "")
        }
    }
    
    func hasToken(withNetwork network: String, andSymbol symbol: String) -> Bool {
        
        findToken(withNetwork: network, andSymbol: symbol) != nil
    }
    
    func findToken(withNetwork network: String, andSymbol symbol: String) -> Web3Token? {
        
        filter { $0.network.name == network && $0.symbol == symbol }.first
    }
    
    func findToken(matching tokenId: String) -> Web3Token? {
        
        filter { $0.coingGeckoId == tokenId }.first
    }
}

private extension Array where Element == TokenPickerViewModel.Section {
    
    var addNoResultsIfNeeded: [TokenPickerViewModel.Section] {
        
        guard isEmpty else { return self }
        
        return [
            .init(name: Localized("tokenPicker.noResults"), items: [])
        ]
    }
}
