// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSwapView: AnyObject {

    func update(with viewModel: TokenSwapViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    func dismissKeyboard()
}

final class TokenSwapViewController: BaseViewController {

    var presenter: TokenSwapPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: FeesPickerView!
    
    private var viewModel: TokenSwapViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension TokenSwapViewController: TokenSwapView {

    func update(with viewModel: TokenSwapViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title

        if collectionView.visibleCells.isEmpty {
            
            collectionView.reloadData()
        } else {
            
            updateCells()
        }
    }
    
    func presentFeePicker(with fees: [FeesPickerViewModel]) {
        
        feesPickerView.present(with: fees, onFeeSelected: makeOnFeeSelected())
        
        let cell = collectionView.visibleCells.first { $0 is TokenSwapCTACollectionViewCell } as! TokenSwapCTACollectionViewCell
        
        print(view.convert(cell.networkFeeButton.bounds, from: cell.networkFeeButton))

    }
    
    @objc func dismissKeyboard() {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension TokenSwapViewController: UICollectionViewDataSource {
    
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
            
        case let .token(token):
            
            let cell = collectionView.dequeue(TokenSwapTokenCollectionViewCell.self, for: indexPath)
            cell.update(with: token, presenter: presenter)
            return cell
            
        case let .send(cta):
            
            let cell = collectionView.dequeue(TokenSwapCTACollectionViewCell.self, for: indexPath)
            cell.update(with: cta, presenter: presenter)
            return cell
        }
    }
}

extension TokenSwapViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        dismissKeyboard()
    }
}

private extension TokenSwapViewController {
    
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
        
        feesPickerView.isHidden = true
    }
    
    func makeOnFeeSelected() -> ((FeesPickerViewModel) -> Void) {
        
        {
            [weak self] item in
            guard let self = self else { return }
            self.presenter.handle(.feeChanged(to: item.id))
        }
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}

private extension TokenSwapViewController {
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            switch sectionIndex {
                
            case 0:
                return self.makeCollectionLayoutSection(
                    sectionIndex: sectionIndex,
                    withCellHeight: Theme.constant.cellHeightSmall
                )
                
            case 1:
                return self.makeCollectionLayoutSection(
                    sectionIndex: sectionIndex,
                    withCellHeight: self.makeTokenCellHeight()
                )
                
            case 2:
                return self.makeCollectionLayoutSection(
                    sectionIndex: sectionIndex,
                    withCellHeight: self.makeCTACellHeight()
                )
                
            default:
                fatalError()
            }
        }
    }
    
    func makeTokenCellHeight() -> CGFloat { 80 }
    
    func makeCTACellHeight() -> CGFloat {
        
        var height: CGFloat = 0
        
        //height += Theme.constant.cellHeightSmall
        //height += Theme.constant.padding
        //height += 36 // fees view
        height += 118
        
        return height
    }
    
    func makeCollectionLayoutSection(
        sectionIndex: Int,
        withCellHeight cellHeight: CGFloat
    ) -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(cellHeight)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionIndex == 0 ? sectionInset : sectionIndex == 1 ? sectionInset * 0.5 : 0,
            leading: sectionInset,
            bottom: sectionIndex == 1 ? 0 : sectionInset,
            trailing: sectionInset
        )
                        
        return section
    }
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let tokenCell as TokenSwapTokenCollectionViewCell:
                
                guard let token = viewModel?.items.token else { return }
                tokenCell.update(with: token, presenter: presenter)
                
            case let ctaCell as TokenSwapCTACollectionViewCell:
                
                guard let cta = viewModel?.items.send else { return }
                ctaCell.update(with: cta, presenter: presenter)

            default:
                
                fatalError()
            }
        }
    }
}
