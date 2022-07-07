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
    
    @objc func dismissKeyboard() {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension TokenSendViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let item = viewModel?.items[indexPath.section] else { fatalError() }
        
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

extension TokenSendViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        dismissKeyboard()
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
        collectionView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}

private extension TokenSendViewController {
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            switch sectionIndex {
                
            case 0:
                return self.makeAddressCollectionLayoutSection(
                    withCellHeight: Theme.constant.cellHeightSmall
                )
                
            case 1:
                return self.makeAddressCollectionLayoutSection(
                    withCellHeight:  self.makeAddressCellHeight()
                )
                
            default:
                fatalError()
            }
        }
    }
    
    func makeAddressCellHeight() -> CGFloat {
        
        var height: CGFloat = 0
        
        height += Theme.constant.padding * 0.5
        height += 22 // Available label height
        height += Theme.constant.padding * 0.5
        height += Theme.constant.cellHeightSmall
        height += Theme.constant.padding
        height += Theme.constant.cellHeightSmall
        
        return height
    }
    
    func makeAddressCollectionLayoutSection(
        withCellHeight cellHeight: CGFloat
    ) -> NSCollectionLayoutSection {
        
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
            heightDimension: .estimated(cellHeight)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset * (cellHeight == Theme.constant.cellHeightSmall ? 2 : 1),
            leading: sectionInset,
            bottom: sectionInset,
            trailing: sectionInset
        )
                        
        return section
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
