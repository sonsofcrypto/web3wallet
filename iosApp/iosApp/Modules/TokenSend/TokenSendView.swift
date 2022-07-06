// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSendView: AnyObject {

    func update(with viewModel: TokenSendViewModel)
    func dismissKeyboard()
}

final class TokenSendViewController: BaseViewController {

    var presenter: TokenSendPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: TokenSendViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension TokenSendViewController: TokenSendView {

    func update(with viewModel: TokenSendViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title

        if collectionView.visibleCells.isEmpty {
            
            collectionView.reloadData()
        } else {
            
            updateCells()
        }
    }
    
    func dismissKeyboard() {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension TokenSendViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let item = viewModel?.items[indexPath.item] else { fatalError() }
        
        switch item {
            
        case let .address(value):
            
            let cell = collectionView.dequeue(TokenSendToCollectionViewCell.self, for: indexPath)
            cell.update(with: value, presenter: presenter)
            return cell
        case let .token(token):
            
            let cell = collectionView.dequeue(TokenSendTokenCollectionViewCell.self, for: indexPath)
            cell.update(with: token, presenter: presenter)
            return cell
        }
    }
}

private extension TokenSendViewController {
    
    func configureUI() {
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        
        collectionView.dataSource = self
        
        collectionView.setCollectionViewLayout(
            makeCollectionLayoutSection(),
            animated: false
        )
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}

private extension TokenSendViewController {
    
    func makeCollectionLayoutSection() -> UICollectionViewLayout {
        
        let inset: CGFloat = Theme.constant.padding * 0.5
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(Theme.constant.cellHeightSmall)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset,
            leading: sectionInset,
            bottom: sectionInset,
            trailing: sectionInset
        )
                        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let addressCell as TokenSendToCollectionViewCell:
                
                guard let address = viewModel?.items.address else { return }
                addressCell.update(with: address, presenter: presenter)

            case let tokenCell as TokenSendTokenCollectionViewCell:
                
                guard let token = viewModel?.items.token else { return }
                tokenCell.update(with: token, presenter: presenter)

            default:
                
                fatalError()
            }
        }
    }
}
