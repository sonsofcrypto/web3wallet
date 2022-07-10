// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenPickerView: AnyObject {

    func update(with viewModel: TokenPickerViewModel)
}

final class TokenPickerViewController: BaseViewController {
    
    enum CollectionTag: Int {
        
        case filters = 1
        case items = 2
    }

    var presenter: TokenPickerPresenter!
    var context: TokenPickerWireframeContext!

    private var viewModel: TokenPickerViewModel?
    
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var searchContainerBox: UIView!
    @IBOutlet weak var searchTextFieldBox: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: TextField!
    @IBOutlet weak var clearSearchButton: UIButton!
    
    private var searchTerm = ""

    private var backgroundGradientTopConstraint: NSLayoutConstraint?
    private var backgroundGradientHeightConstraint: NSLayoutConstraint?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }
}

extension TokenPickerViewController {
    
    @IBAction func clearSearchInputText() {
        
        searchTextField.text = ""
        presenter.handle(.search(searchTerm: ""))
    }
}

extension TokenPickerViewController: TokenPickerView {

    func update(with viewModel: TokenPickerViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title
        
        clearSearchButton.isHidden = searchTextField.text?.isEmpty ?? true
        
        filtersCollectionView.isHidden = viewModel.filters().isEmpty
        filtersCollectionView.reloadData()
        itemsCollectionView.reloadData()
        
        updateNavigationBarIcons()
        
        updateBackgroundGradient(after: 0.05)
    }
}

private extension TokenPickerViewController {
    
    func configureUI() {
        
        view.backgroundColor = Theme.colour.gradientBottom
        
        searchContainerBox.backgroundColor = Theme.colour.navBarBackground
        
        searchTextFieldBox.backgroundColor = Theme.colour.fillTertiary
        searchTextFieldBox.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        searchImageView.tintColor = Theme.colour.labelSecondary
        
        searchTextField.backgroundColor = .clear
        searchTextField.font = Theme.font.title3
        searchTextField.text = nil
        searchTextField.delegate = self
        
        clearSearchButton.isHidden = true
        clearSearchButton.tintColor = Theme.colour.labelSecondary
        
        itemsCollectionView.register(
            TokenPickerGroupCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(TokenPickerGroupCell.self)"
        )

        itemsCollectionView.setCollectionViewLayout(
            UICollectionViewCompositionalLayout(section: makeItemsCollectionLayoutSection()),
            animated: false
        )
        
        addCustomBackgroundGradientView()
    }
    
    func updateNavigationBarIcons() {
        
        guard let viewModel = viewModel else { return }
        
        if viewModel.allowMultiSelection {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "plus"),
                style: .plain,
                target: self,
                action: #selector(addCustomToken)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: Localized("done"),
                style: .plain,
                target: self,
                action: #selector(doneTapped)
            )
            itemsCollectionView.allowsMultipleSelection = viewModel.allowMultiSelection
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: Localized("close"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        }
    }

    @objc func addCustomToken() {
        
        presenter.handle(.addCustomToken)
    }

    @objc func doneTapped() {
        
        presenter.handle(.done)
    }

    @objc func closeTapped() {
        
        presenter.handle(.dismiss)
    }
    
    func updateBackgroundGradient(after delay: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.updateBackgroundGradient()
        }
    }
    
    func updateBackgroundGradient() {
        
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }
    
    func updateBackgroundGradientTopConstraint() {
        
        let constant: CGFloat
        if itemsCollectionView.contentOffset.y < 0 {
            constant = 0
        } else {
            constant = -itemsCollectionView.contentOffset.y
        }
        backgroundGradientTopConstraint?.constant =  constant
    }
}

extension TokenPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return 1

        case CollectionTag.items.rawValue:
            
            return viewModel?.sections().count ?? 0
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return viewModel?.filters().count ?? 0

        case CollectionTag.items.rawValue:
            
            guard let section = viewModel?.sections()[section] else {
                return 0
            }

            return section.items.count
            
        default:
            
            fatalError("Collection not implemented")
        }
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
            collectionView.tag == CollectionTag.items.rawValue,
            let section = viewModel?.sections()[indexPath.section]
        else { fatalError() }
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let supplementary = collectionView.dequeue(
                TokenPickerGroupCell.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: section)
            return supplementary
            
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

extension TokenPickerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
       
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:
            
            filterSelectedAt(indexPath: indexPath)
        case CollectionTag.items.rawValue:
            
            itemSelectedAt(indexPath: indexPath)
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.tag == CollectionTag.items.rawValue else { return }
    
        updateBackgroundGradientTopConstraint()
        
        dismissKeyboard()
    }
}

extension TokenPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
                
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return .init(width: 56, height: collectionView.frame.height)

        default:
            
            fatalError("Collection not implemented")
        }
    }
}

extension TokenPickerViewController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        presenter.handle(.search(searchTerm: textField.text ?? ""))
    }
}

private extension TokenPickerViewController {
    
    func filterSelectedAt(indexPath: IndexPath) {
        
        guard let filter = viewModel?.filters()[indexPath.row] else { return }
        
        presenter.handle(.selectFilter(filter))
    }
    
    func itemSelectedAt(indexPath: IndexPath) {
        
        guard let section = viewModel?.sections()[indexPath.section] else {
            fatalError()
        }
        let token = section.items[indexPath.item]
        presenter.handle(.selectItem(token))
    }
    
    func collectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return filterCollectionViewCell(at: indexPath, for: collectionView)

        case CollectionTag.items.rawValue:
            
            return itemCollectionViewCell(at: indexPath, for: collectionView)
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    
    func filterCollectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        guard let filter = viewModel?.filters()[indexPath.item] else {
            fatalError()
        }
        
        let cell = collectionView.dequeue(
            TokenPickerFilterCell.self,
            for: indexPath
        )
        cell.update(
            with: filter
        )
        return cell
    }
    
    func itemCollectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        guard let section = viewModel?.sections()[indexPath.section] else {
            fatalError()
        }
        
        let token = section.items[indexPath.item]
                    
        let cell = collectionView.dequeue(
            TokenPickerItemCell.self,
            for: indexPath
        )
        cell.update(
            with: token
        )
        return cell
    }
    
    @objc func dismissKeyboard() {
        
        searchTextField.resignFirstResponder()
    }
}

private extension TokenPickerViewController {
    
    func makeItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(context.source.isSend ? 64 : 44)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(54)
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

extension TokenPickerViewController: UIScrollViewDelegate {

    func addCustomBackgroundGradientView() {

        // 1 - Add gradient
        let backgroundGradient = GradientView()
        backgroundGradient.isDashboard = true
        view.insertSubview(backgroundGradient, at: 0)
        
        backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = backgroundGradient.topAnchor.constraint(
            equalTo: searchContainerBox.bottomAnchor
        )
        self.backgroundGradientTopConstraint = topConstraint
        topConstraint.isActive = true

        backgroundGradient.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        ).isActive = true

        backgroundGradient.trailingAnchor.constraint(
            equalTo: view.trailingAnchor
        ).isActive = true

        let heightConstraint = backgroundGradient.heightAnchor.constraint(
            equalToConstant: backgroundGradientHeight
        )
        self.backgroundGradientHeightConstraint = heightConstraint
        heightConstraint.isActive = true
    }

    var backgroundGradientHeight: CGFloat {
        
        if itemsCollectionView.frame.size.height > itemsCollectionView.contentSize.height {
            
            return itemsCollectionView.frame.size.height
        } else {
            
            return itemsCollectionView.contentSize.height
        }
    }
}

