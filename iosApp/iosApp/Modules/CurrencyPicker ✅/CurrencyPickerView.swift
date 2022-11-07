// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyPickerViewController: BaseViewController {
    var presenter: CurrencyPickerPresenter!
    var context: CurrencyPickerWireframeContext!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchContainerBox: UIView!
    @IBOutlet weak var searchTextFieldBox: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: TextField!
    @IBOutlet weak var dividerLineView: UIView!
    
    private var viewModel: CurrencyPickerViewModel?
    private var searchTerm = ""
    private var bottomKeyboardLayoutConstraint: NSLayoutConstraint!
    
    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.handle(event_______________: .WillDismiss())
    }
}

extension CurrencyPickerViewController: CurrencyPickerView {

    func update(viewModel___________ viewModel: CurrencyPickerViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        collectionView.reloadData()
        updateNavigationBarIcons()
    }
}

private extension CurrencyPickerViewController {
    
    func configureUI() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard),
            name: UIApplication.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboard),
            name: UIApplication.keyboardWillHideNotification,
            object: nil
        )
        view.backgroundColor = Theme.colour.gradientBottom
        searchContainerBox.backgroundColor = Theme.colour.navBarBackground
        searchTextFieldBox.backgroundColor = Theme.colour.fillQuaternary
        searchTextFieldBox.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        searchImageView.tintColor = Theme.colour.labelSecondary
        searchTextField.backgroundColor = .clear
        searchTextField.text = nil
        searchTextField.delegate = self
        searchTextField.placeholder = Localized("search")
        searchTextField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(clearSearchAnddismissKeyboard)))
        )
        collectionView.register(
            CurrencyPickerSectionCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(CurrencyPickerSectionCell.self)"
        )
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
            animated: false
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Smell
        bottomKeyboardLayoutConstraint = collectionView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor,
            constant: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        )
        bottomKeyboardLayoutConstraint.priority = .required
        bottomKeyboardLayoutConstraint.isActive = true
    }
    
    @objc func showKeyboard() { addCollectionViewBottomInset() }
    
    @objc func hideKeyboard() { collectionView.contentInset = .zero }
    
    func addCollectionViewBottomInset() {
        // TODO: Smell
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        collectionView.contentInset = .init(top: 0, left: 0, bottom: bottom, right: 0)
    }
    
    func updateNavigationBarIcons() {
        guard let viewModel = viewModel else { return }
        if viewModel.allowMultipleSelection {
            if viewModel.showAddCustomCurrency {
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: "plus".assetImage,
                    style: .plain,
                    target: self,
                    action: #selector(addCustomCurrency)
                )
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: Localized("done"),
                style: .plain,
                target: self,
                action: #selector(doneTapped)
            )
        } else {
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
            if viewModel.showAddCustomCurrency {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: "plus".assetImage,
                    style: .plain,
                    target: self,
                    action: #selector(addCustomCurrency)
                )
            }
        }
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = viewModel.allowMultipleSelection
    }

    @objc func addCustomCurrency() { presenter.handle(event_______________: .AddCustomCurrency()) }

    @objc func doneTapped() { presenter.handle(event_______________: .Dismiss()) }

    @objc func navBarLeftActionTapped() {
        presenter.handle(event_______________: .Dismiss())
    }
}

extension CurrencyPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let section = viewModel?.sections[section]
        return section?.networks?.count
        ?? section?.favouriteCurrencies?.count
        ?? section?.currencies?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionViewCell(at: indexPath, for: collectionView)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let section = viewModel?.sections[indexPath.section]
        else { fatalError() }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let supplementary = collectionView.dequeue(
                CurrencyPickerSectionCell.self, for: indexPath, kind: kind
            )
            supplementary.update(with: section)
            return supplementary
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

extension CurrencyPickerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError()
        }
        if section.networks != nil {
            presenter.handle(event_______________: .SelectNetwork(idx: indexPath.item.int32))
        } else if section.favouriteCurrencies != nil {
            presenter.handle(event_______________: .SelectFavouriteCurrency(idx: indexPath.item.int32))
        } else if section.currencies != nil {
            presenter.handle(event_______________: .SelectCurrency(idx: indexPath.item.int32))
        }
    }
}

extension CurrencyPickerViewController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        presenter.handle(event_______________: .Search(searchTerm: textField.text ?? ""))
    }
}

private extension CurrencyPickerViewController {
        
    func collectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError()
        }
        if let networks = section.networks {
            let cell = collectionView.dequeue(CurrencyPickerNetworkCell.self, for: indexPath)
            cell.update(with: networks[indexPath.item])
            return cell
        }
        if let favouriteCurrencies = section.favouriteCurrencies {
            let cell = collectionView.dequeue(CurrencyPickerTokenCell.self, for: indexPath)
            cell.update(with: favouriteCurrencies[indexPath.item])
            return cell
        }
        if let currencies = section.currencies {
            let cell = collectionView.dequeue(CurrencyPickerTokenCell.self, for: indexPath)
            cell.update(with: currencies[indexPath.item])
            return cell
        }
        fatalError("Section not handled.")
    }
    
    @objc func clearSearchAnddismissKeyboard() {
        searchTextField.text = ""
        dismissKeyboard()
    }

    @objc func dismissKeyboard() {
        searchTextField.resignFirstResponder()
    }
}

private extension CurrencyPickerViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (idx, _) in
            guard let self = self else { return nil }
            guard let section = self.viewModel?.sections[idx] else { return nil }
            if section.networks != nil { return self.networkItemsCollectionLayoutSection() }
            else if section.favouriteCurrencies != nil { return self.currencyItemsCollectionLayoutSection() }
            else if section.currencies != nil { return self.currencyItemsCollectionLayoutSection() }
            else { return nil }
        }
        return layout
    }
    
    func networkItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(144),
            heightDimension: .absolute(56)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Theme.constant.padding.half
        section.contentInsets = .init(
            top: 0,
            leading: Theme.constant.padding,
            bottom: 0,
            trailing: Theme.constant.padding
        )
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
    
    func currencyItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(56)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
}

private extension CurrencyPickerViewModel.Section {
    var networks: [CurrencyPickerViewModel.Network]? {
        (self as? CurrencyPickerViewModel.SectionNetworks)?.items
    }
    var favouriteCurrencies: [CurrencyPickerViewModel.Currency]? {
        (self as? CurrencyPickerViewModel.SectionFavouriteCurrencies)?.items
    }
    var currencies: [CurrencyPickerViewModel.Currency]? {
        (self as? CurrencyPickerViewModel.SectionCurrencies)?.items
    }
}
