// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSwapView: AnyObject {

    func update(with viewModel: TokenSwapViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    //func presentReviewSwap(with fees: [FeesPickerViewModel])
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
        
        dismissKeyboard()
                
        let cell = collectionView.visibleCells.first { $0 is TokenSwapMarketCollectionViewCell } as! TokenSwapMarketCollectionViewCell

        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: fees,
            onFeeSelected: makeOnFeeSelected(),
            at: .init(
                x: Theme.constant.padding,
                y: fromFrame.midY
            )
        )
    }
    
    @objc func dismissKeyboard() {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension TokenSwapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let item = viewModel?.items[indexPath.row] else { fatalError() }
        
        switch item {
            
        case let .swap(swap):
            
            let cell = collectionView.dequeue(TokenSwapMarketCollectionViewCell.self, for: indexPath)
            cell.update(with: swap, handler: makeTokenSwapHandler())
            return cell
            
        case .limit:

            let cell = collectionView.dequeue(TokenSwapLimitCollectionViewCell.self, for: indexPath)
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
        
        collectionView.isPagingEnabled = true
        
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
                    withCellHeight: self.makeSwapCellHeight()
                )
                
            default:
                fatalError()
            }
        }
    }
    
    func makeSwapCellHeight() -> CGFloat {
        var height: CGFloat = 0
        
        height += 80
        height += 4
        height += 24
        height += 4
        height += 80
        
        height += 32 // Space
        height += 32 // provider
        height += 8
        height += 24 // slippage fee
        height += 8
        height += 24 // price fee
        height += 8
        height += 24 // estimated fee
        height += 16
        height += 46 // review
        
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
        let screenWidth: CGFloat = (view.bounds.width - Theme.constant.padding)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .estimated(cellHeight)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        outerGroup.contentInsets = .init(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: 0,
            leading: sectionInset,
            bottom: 0,
            trailing: sectionInset
        )
        section.orthogonalScrollingBehavior = .groupPaging
                        
        return section
    }
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let tokenCell as TokenSwapMarketCollectionViewCell:
                
                guard let swap = viewModel?.items.swap else { return }
                tokenCell.update(with: swap, handler: makeTokenSwapHandler())
                
            case let _ as TokenSwapLimitCollectionViewCell:
                
                break

            default:
                
                fatalError()
            }
        }
    }
    
    func makeTokenSwapHandler() -> TokenSwapMarketCollectionViewCell.Handler {
        
        .init(
            onTokenFromAmountChanged: makeOnTokenFromAmountChanged(),
            onTokenToAmountChanged: makeOnTokenToAmountChanged(),
            onSwapFlip: makeOnSwapFlip(),
            onNetworkFeesTapped: makeOnNetworkFeesTapped(),
            onCTATapped: makeOnCTATapped()
        )
    }
    
    func makeOnTokenFromAmountChanged() -> (Double) -> Void {
        
        {
            [weak self] amount in
            guard let self = self else { return }
            self.presenter.handle(.tokenFromChanged(to: amount))
        }
    }
    
    func makeOnTokenToAmountChanged() -> (Double) -> Void {
        
        {
            [weak self] amount in
            guard let self = self else { return }
            self.presenter.handle(.tokenToChanged(to: amount))
        }
    }
    
    func makeOnSwapFlip() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.swapFlip)
        }
    }
    
    func makeOnNetworkFeesTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.feeTapped)
        }
    }
    
    func makeOnCTATapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.review)
        }
    }
}
