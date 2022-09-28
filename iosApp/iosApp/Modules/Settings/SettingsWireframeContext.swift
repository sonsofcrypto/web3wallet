// Created by web3d4v on 15/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct SettingsWireframeContext {
    let title: String
    let groups: [Group]
    
    struct Group {
        let title: String?
        let items: [Setting]
        let footer: Footer?
        
        struct Footer {
            let text: String
            let textAlignment: SettingsViewModel.Section.Footer.TextAlignment
        }
    }
    
    static var `default`: SettingsWireframeContext {
        .init(
            title: Localized("settings"),
            groups: [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.themes"),
                            type: .item(.theme)
                        ),
                        .init(
                            title: Localized("settings.root.improvementProposals"),
                            type: .item(
                                item: .improvement,
                                action: .improvementProposals
                            )
                        ),
                        .init(
                            title: Localized("settings.root.developerMenu"),
                            type: .item(.debug)
                        )
                    ],
                    footer: nil
                ),
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.about"),
                            type: .item(.about)
                        )
                    ],
                    footer: nil
                ),
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.feedback"),
                            type: .item(
                                item: .feedback,
                                action: .feedbackReport
                            )
                        )
                    ],
                    footer: nil
                )
            ]
        )
    }
}
