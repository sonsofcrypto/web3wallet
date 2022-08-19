// Created by web3d3v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

protocol ThemePickerView: AnyObject {

}

class ThemePickerViewController: UIViewController, ThemePickerView {
    @IBOutlet weak var collectionView: UICollectionView!

    private var firstAppear: Bool = true

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if firstAppear && !collectionView.visibleCells.isEmpty {
//            let cell = collectionView.visibleCells.first as? ThemePickerCell
//            cell?.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            firstAppear = false
//            print("=== here")
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppear = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.springAnimate {
                self.collectionView.visibleCells.forEach {
                    ($0 as? ThemePickerCell)?.layer.transform = CATransform3DIdentity
                }
            }
        }


    }
}

extension ThemePickerViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ThemePickerCell.self, for: indexPath)
        cell.imageView.image = UIImage(named: "theme_image_0\(indexPath.item)")
        if firstAppear {
            cell.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1)
        }
        return cell
    }
}

extension ThemePickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return view.bounds.size
    }
}


extension ThemePickerViewController: UICollectionViewDelegate {


}
