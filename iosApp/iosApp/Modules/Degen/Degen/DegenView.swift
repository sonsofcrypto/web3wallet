// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenView: AnyObject {

    func update(with viewModel: DegenViewModel)
    func popToRootAndRefresh()
}

final class DegenViewController: BaseViewController {

    var presenter: DegenPresenter!

    @IBOutlet weak var collectionView: CollectionView!

    private var backgroundGradientTopConstraint: NSLayoutConstraint?
    private var backgroundGradientHeightConstraint: NSLayoutConstraint?

    private var viewModel: DegenViewModel?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavAndTabBarItem()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureNavAndTabBarItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }

}

extension DegenViewController: DegenView {

    func update(with viewModel: DegenViewModel) {
        
        self.viewModel = viewModel
        collectionView?.reloadData()
        
        updateBackgroundGradient(after: 0.05)
    }
    
    func popToRootAndRefresh() {
        
        navigationController?.popToRootViewController(animated: false)
        presenter.present()
    }
}

extension DegenViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel?.sections.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        guard let section = viewModel?.sections[section] else {
            
            return 0
        }
        
        switch section {
        case .header:
            return 1
        case let .group(items):
            return items.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
        
        switch section {
            
        case let .header(header):
            let cell = collectionView.dequeue(DegenSectionViewCell.self, for: indexPath)
            cell.update(with: header)
            return cell
            
        case let .group(items):
            let item = items[indexPath.item]
            let cell = collectionView.dequeue(DegenViewCell.self, for: indexPath)
            cell.update(with: item, showSeparator: items.last != item)
            return cell
        }
    }
}

extension DegenViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        guard let section = viewModel?.sections[indexPath.section] else { return }
        
        guard case let DegenViewModel.Section.group(items) = section else { return }
        
        if items[indexPath.row].isEnabled {
            presenter.handle(.didSelectCategory(idx: indexPath.item))
        } else {
            presenter.handle(.comingSoon)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateBackgroundGradientTopConstraint()
    }
}

extension DegenViewController {
    
    func configureUI() {
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )

        collectionView.overScrollView.image = "overscroll_degen".assetImage
        
        addCustomBackgroundGradientView()
    }

    func configureNavAndTabBarItem() {
        title = Localized("degen")
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            guard let viewModel = self.viewModel else { return nil }
            
            switch viewModel.sections[sectionIndex] {
                
            case .header:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: false,
                    sectionIndex: sectionIndex
                )

            case .group:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: true,
                    sectionIndex: sectionIndex
                )
            }
        }
        layout.register(
            DgenCellBackgroundSupplementaryView.self,
            forDecorationViewOfKind: "background"
        )
        return layout
    }
  
    func makeCollectionLayoutSection(
        withBackgroundDecoratorView addBackgroundDecorator: Bool,
        sectionIndex: Int
    ) -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        //item.contentInsets = .paddingHalf
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        //outerGroup.contentInsets = .paddingHalf
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = sectionIndex.isMultiple(of: 2) ?
            .init(
                top: sectionIndex == 0 ? Theme.constant.padding : 0,
                leading: Theme.constant.padding,
                bottom: 0,
                trailing: Theme.constant.padding
            ) :
            .init(
                top: Theme.constant.padding,
                leading: Theme.constant.padding,
                bottom: sectionIndex == 0 ? 0 : Theme.constant.padding,
                trailing: Theme.constant.padding
            )
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        
        if addBackgroundDecorator {

            let backgroundItem = NSCollectionLayoutDecorationItem.background(
                elementKind: "background"
            )
            backgroundItem.contentInsets = .padding
            section.decorationItems = [backgroundItem]
        }
        
        return section
    }
}

extension DegenViewController: UIScrollViewDelegate {

    func addCustomBackgroundGradientView() {

        // 1 - Add gradient
        let backgroundGradient = ThemeGradientView()
        view.insertSubview(backgroundGradient, at: 0)
        
        backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = backgroundGradient.topAnchor.constraint(
            equalTo: collectionView.topAnchor
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
        
        if collectionView.frame.size.height > collectionView.contentSize.height {
            
            return collectionView.frame.size.height
        } else {
            
            return collectionView.contentSize.height
        }
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
        
        // NOTE: Doing this guard since this method can be called before the view has called
        // view did load (because of networksService sending an update) that a network has
        // been selected
        guard let collectionView = collectionView else { return }
        
        let constant: CGFloat
        if collectionView.contentOffset.y < 0 {
            constant = 0
        } else {
            constant = -collectionView.contentOffset.y
        }
        
        guard constant > collectionView.frame.size.height - collectionView.contentSize.height else { return }
        backgroundGradientTopConstraint?.constant =  constant
    }
}

