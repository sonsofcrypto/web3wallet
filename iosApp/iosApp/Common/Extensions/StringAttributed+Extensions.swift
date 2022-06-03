// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension String {
    
    func attributtedString(
        with mainFont: UIFont,
        and mainColour: UIColor,
        updating keywords: [String],
        withColour colour: UIColor,
        andFont font: UIFont
    ) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: mainFont,
                .foregroundColor: mainColour
            ]
        )
        keywords.forEach { keyword in
            
            let range = (lowercased() as NSString).range(of: keyword.lowercased())
            attributedString.setAttributes(
                [
                    .foregroundColor: colour,
                    .font: font
                ],
                range: range
            )
        }
        return attributedString
    }
}
