// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSwapView: AnyObject {

    func update(with viewModel: TokenSwapViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    //func presentReviewSwap(with fees: [FeesPickerViewModel])
    func loading()
    func dismissKeyboard()
}

final class TokenSwapViewController: BaseViewController {

    var presenter: TokenSwapPresenter!

    private weak var segmentControl: SegmentedControl!
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
    
    func loading() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let cell as TokenSwapMarketCollectionViewCell:
                cell.showLoading()
                
            default:
                break
            }
        }
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        segmentControl.selectedSegmentIndex = indexPath.row == 0 ? 1 : 0
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
        
        let segmentControl = makeSegmentedControl()
        navigationItem.titleView = segmentControl
        
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
    
    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        
        let targetIndexPath = IndexPath(row: sender.selectedSegmentIndex, section: 0)
        collectionView.selectItem(
            at: targetIndexPath,
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
    
    func makeSegmentedControl() -> SegmentedControl {
        
        let segmentControl = SegmentedControl()
        segmentControl.insertSegment(
            withTitle: Localized("tokenSwap.segment.swap"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("tokenSwap.segment.limit"),
            at: 1,
            animated: false
        )
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)

        self.segmentControl = segmentControl
        
        return segmentControl
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
        section.visibleItemsInvalidationHandler = {
            // [weak self] visibleItems, point, environment in
            [weak self] (_, _, _) in
            guard let self = self else { return }
            self.dismissKeyboard()
        }
                        
        return section
    }
}

private extension TokenSwapViewController {
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let tokenCell as TokenSwapMarketCollectionViewCell:
                
                guard let swap = viewModel?.items.swap else { return }
                tokenCell.update(with: swap, handler: makeTokenSwapHandler())
                
            case _ as TokenSwapLimitCollectionViewCell:
                
                break

            default:
                
                fatalError()
            }
        }
    }
}

private extension TokenSwapViewController {
    
    func makeTokenSwapHandler() -> TokenSwapMarketCollectionViewCell.Handler {
        
        .init(
            onTokenFromTapped: makeOnTokenFromTapped(),
            onTokenFromAmountChanged: makeOnTokenFromAmountChanged(),
            onTokenToTapped: makeOnTokenToTapped(),
            onTokenToAmountChanged: makeOnTokenToAmountChanged(),
            onSwapFlip: makeOnSwapFlip(),
            onNetworkFeesTapped: makeOnNetworkFeesTapped(),
            onCTATapped: makeOnCTATapped()
        )
    }
    
    func makeOnTokenFromTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            self.presenter.handle(.tokenFromTapped)
        }
    }
    
    func makeOnTokenFromAmountChanged() -> (Double) -> Void {
        
        {
            [weak self] amount in
            guard let self = self else { return }
            self.presenter.handle(.tokenFromChanged(to: amount))
        }
    }
    
    func makeOnTokenToTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            self.presenter.handle(.tokenToTapped)
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
