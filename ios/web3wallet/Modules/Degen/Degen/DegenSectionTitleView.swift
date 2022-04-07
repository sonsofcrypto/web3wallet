//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class DegenSectionTitleView: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
}

// MARK: - DegentViewModel

extension DegenSectionTitleView {

    func update(with viewModel: DegenViewModel?) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        label.attributedText = NSAttributedString(
            string: viewModel?.sectionTitle ?? "",
            attributes: [
                .font: AppTheme.current.fonts.cellDetail,
                .foregroundColor: AppTheme.current.colors.textColorTertiary,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
