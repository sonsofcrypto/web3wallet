// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct AlertContext {
    let title: String?
    let media: Media?
    let message: String?
    let actions: [Action]
    let contentHeight: CGFloat
    
    enum Media {
        case image(named: String, size: CGSize)
        case gift(named: String, size: CGSize)
    }

    struct Action {
        let title: String
        let type: `Type`
        let action: TargetActionViewModel?
        
        enum `Type` {
            case primary
            case secondary
            case destructive
        }
    }
}

extension AlertContext {
    
    static func underConstructionAlert(
        onOkTapped: TargetActionViewModel? = nil
    ) -> Self {
        .init(
            title: Localized("alert.underConstruction.title"),
            media: .gift(named: "under-construction", size: .init(width: 240, height: 285)),
            message: Localized("alert.underConstruction.message"),
            actions: [
                .init(
                    title: Localized("OK"),
                    type: .primary,
                    action: onOkTapped
                )
            ],
            contentHeight: 500
        )
    }
    
    static func error(
        title: String = Localized("error.alert.title"),
        message: String,
        onOkTapped: TargetActionViewModel? = nil,
        contentHeight: CGFloat = 500
    ) -> Self {
        .init(
            title: title,
            // TODO: @Annon to provide nice gift
            media: .gift(named: "under-construction", size: .init(width: 240, height: 285)),
            message: message,
            actions: [
                .init(
                    title: Localized("OK"),
                    type: .primary,
                    action: onOkTapped
                )
            ],
            contentHeight: contentHeight
        )
    }
}
