// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencySendViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feesPickerView: NetworkFeePickerView!

    var presenter: CurrencySendPresenter!

    private var viewModel: CurrencySendViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }    
}

extension CurrencySendViewController {

    func update(with viewModel: CurrencySendViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        if collectionView.visibleCells.isEmpty { collectionView.reloadData() }
        else { updateCells() }
    }
    
    func presentNetworkFeePicker(networkFees: [NetworkFee]) {
        dismissKeyboard()
        let cell = collectionView.visibleCells.first {
            $0 is CurrencySendCTACollectionViewCell
        } as! CurrencySendCTACollectionViewCell
        let fromFrame = feesPickerView.convert(
            cell.networkFeeView.networkFeeButton.bounds,
            from: cell.networkFeeView.networkFeeButton
        )
        feesPickerView.present(
            with: networkFees,
            onFeeSelected: makeOnFeeSelected(),
            at: .init(x: Theme.constant.padding, y: fromFrame.midY)
        )
    }
    
    @objc func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

extension CurrencySendViewController: UICollectionViewDataSource {
    
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
        if let input = item as? CurrencySendViewModel.ItemAddress {
            let cell = collectionView.dequeue(CurrencySendToAddressCollectionViewCell.self, for: indexPath)
            cell.update(with: input.data, handler: addressHandler())
            return cell
        }
        if let input = item as? CurrencySendViewModel.ItemCurrency {
            let cell = collectionView.dequeue(CurrencySendCurrencyCollectionViewCell.self, for: indexPath)
            cell.update(with: input.data, handler: currencyHandler())
            return cell
        }
        if let input = item as? CurrencySendViewModel.ItemSend {
            let cell = collectionView.dequeue(CurrencySendCTACollectionViewCell.self, for: indexPath)
            cell.update(with: input.data, handler: ctaHandler())
            return cell
        }
        fatalError("Item not implemented")
    }
}

extension CurrencySendViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}

private extension CurrencySendViewController {
    
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
                image: .init(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(navBarLeftActionTapped)
            )
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(tapGesture)
        collectionView.setCollectionViewLayout(compositionalLayout(), animated: false)
        feesPickerView.isHidden = true
    }
    
    func makeOnFeeSelected() -> ((NetworkFee) -> Void) {
        { [weak self] item in self?.onTapped(CurrencySendPresenterEvent.NetworkFeeChanged(value: item))() }
    }
    
    @objc func navBarLeftActionTapped() {
        presenter.handle(event: CurrencySendPresenterEvent.Dismiss())
    }
}

private extension CurrencySendViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            switch sectionIndex {
            case 0: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            case 1: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            case 2: return self.collectionLayoutSection(sectionIndex: sectionIndex)
            default: fatalError()
            }
        }
    }
    
    func collectionLayoutSection(sectionIndex: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
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
            if let cell = $0 as? CurrencySendToAddressCollectionViewCell {
                guard let address = viewModel?.items.address else { return }
                cell.update(with: address, handler: addressHandler())
            }
            if let cell = $0 as? CurrencySendCurrencyCollectionViewCell {
                guard let currency = viewModel?.items.currency else { return }
                cell.update(with: currency, handler: currencyHandler())
            }
            if let cell = $0 as? CurrencySendCTACollectionViewCell {
                guard let send = viewModel?.items.send else { return }
                cell.update(with: send, handler: ctaHandler())
            }
        }
    }
}

private extension CurrencySendViewController {
    
    func addressHandler() -> NetworkAddressPickerView.Handler {
        .init(
            onAddressChanged: onAddressChanged(),
            onQRCodeScanTapped: onTapped(CurrencySendPresenterEvent.QrCodeScan()),
            onPasteTapped: onPasteFromKeyboard(),
            onSaveTapped: onTapped(CurrencySendPresenterEvent.SaveAddress())
        )
    }
    
    func onPasteFromKeyboard() -> () -> Void {
        { [weak self] in
            self?.onTapped(
                CurrencySendPresenterEvent.PasteAddress(value: UIPasteboard.general.string ?? "")
            )()
        }
    }

    func onAddressChanged() -> (String) -> Void {
        { [weak self] value in self?.onTapped(CurrencySendPresenterEvent.AddressChanged(value: value))()}
    }
    
    func currencyHandler() -> CurrencySendCurrencyCollectionViewCell.Handler {
        .init(
            onCurrencyTapped: onTapped(CurrencySendPresenterEvent.SelectCurrency()),
            onAmountChanged: onAmountChanged()
        )
    }
    
    func onAmountChanged() -> (BigInt) -> Void {
        { [weak self] value in self?.onTapped(CurrencySendPresenterEvent.AmountChanged(value: value))() }
    }
    
    func ctaHandler() -> CurrencySendCTACollectionViewCell.Handler {
        .init(
            onNetworkFeesTapped: onTapped(CurrencySendPresenterEvent.NetworkFeeTapped()),
            onCTATapped: onTapped(CurrencySendPresenterEvent.Review())
        )
    }
    
    func onTapped(_ event: CurrencySendPresenterEvent) -> () -> Void {
        { [weak self] in self?.presenter.handle(event: event) }
    }
}

extension Array where Element == CurrencySendViewModel.Item {
    var address: NetworkAddressPickerViewModel? {
        let item = first { $0 is CurrencySendViewModel.ItemAddress }
        return (item as? CurrencySendViewModel.ItemAddress)?.data
    }

    var currency: CurrencyAmountPickerViewModel? {
        let item = first { $0 is CurrencySendViewModel.ItemCurrency }
        return (item as? CurrencySendViewModel.ItemCurrency)?.data
    }

    var send: CurrencySendViewModel.SendViewModel? {
        let item = first { $0 is CurrencySendViewModel.ItemSend }
        return (item as? CurrencySendViewModel.ItemSend)?.data
    }
}
