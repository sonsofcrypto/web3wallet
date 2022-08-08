// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSendView: AnyObject {

    func update(with viewModel: TokenSendViewModel)
    func presentFeePicker(with fees: [FeesPickerViewModel])
    func dismissKeyboard()
}

final class TokenSendViewController: BaseViewController {

    var presenter: TokenSendPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: FeesPickerView!
    
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
    
    func presentFeePicker(with fees: [FeesPickerViewModel]) {
        
        dismissKeyboard()
                
        let cell = collectionView.visibleCells.first { $0 is TokenSendCTACollectionViewCell } as! TokenSendCTACollectionViewCell

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
            cell.update(with: value, handler: makeTokenSendTokenHandler())
            return cell
        case let .token(token):
            
            let cell = collectionView.dequeue(TokenSendTokenCollectionViewCell.self, for: indexPath)
            cell.update(with: token, handler: makeTokenSendTokenHandler())
            return cell
            
        case let .send(cta):
            
            let cell = collectionView.dequeue(TokenSendCTACollectionViewCell.self, for: indexPath)
            cell.update(with: cta, handler: makeTokenSendCTAHandler())
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
                
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: "chevron.left".assetImage,
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: Localized("close"),
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        }
        
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

private extension TokenSendViewController {
    
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
        height += Theme.constant.padding * 2
        height += 24
        height += Theme.constant.padding
        height += Theme.constant.buttonPrimaryHeight
        
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
            top: sectionIndex == 0 ? sectionInset : 0,
            leading: sectionInset,
            bottom: sectionIndex == 1 ? 0 : sectionInset,
            trailing: sectionInset
        )
                        
        return section
    }
    
    func updateCells() {
        
        collectionView.visibleCells.forEach {
            
            switch $0 {
                
            case let addressCell as TokenSendToCollectionViewCell:
                
                guard let address = viewModel?.items.address else { return }
                addressCell.update(with: address, handler: makeTokenSendTokenHandler())

            case let tokenCell as TokenSendTokenCollectionViewCell:
                
                guard let token = viewModel?.items.token else { return }
                tokenCell.update(with: token, handler: makeTokenSendTokenHandler())
                
            case let ctaCell as TokenSendCTACollectionViewCell:
                
                guard let cta = viewModel?.items.send else { return }
                ctaCell.update(with: cta, handler: makeTokenSendCTAHandler())

            default:
                
                fatalError()
            }
        }
    }
}

private extension TokenSendViewController {
    
    func makeTokenSendTokenHandler() -> TokenEnterAddressView.Handler {
        
        .init(
            onAddressChanged: makeOnAddressChanged(),
            onQRCodeScanTapped: makeOnQRCodeScanTapped(),
            onPasteTapped: makeOnPasteTapped(),
            onSaveTapped: makeOnSaveTapped()
        )
    }

    func makeOnAddressChanged() -> (String) -> Void {
        
        {
            [weak self] value in
            guard let self = self else { return }
            self.presenter.handle(.addressChanged(to: value))
        }
    }
    
    func makeOnQRCodeScanTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.qrCodeScan)
        }
    }
    
    func makeOnPasteTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.pasteAddress)
        }
    }
    
    func makeOnSaveTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.saveAddress)
        }
    }
    
    func makeTokenSendTokenHandler() -> TokenSendTokenCollectionViewCell.Handler {
        
        .init(
            onTokenTapped: makeOnTokenTapped(),
            onTokenChanged: makeOnTokenChanged()
        )
    }
    
    func makeOnTokenTapped() -> () -> Void {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.presenter.handle(.selectToken)
        }
    }
    
    func makeOnTokenChanged() -> (Double) -> Void {
        
        {
            [weak self] value in
            guard let self = self else { return }
            self.presenter.handle(.tokenChanged(to: value))
        }
    }
    
    func makeTokenSendCTAHandler() -> TokenSendCTACollectionViewCell.Handler {
        
        .init(
            onNetworkFeesTapped: makeOnNetworkFeesTapped(),
            onCTATapped: makeOnCTATapped()
        )
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
