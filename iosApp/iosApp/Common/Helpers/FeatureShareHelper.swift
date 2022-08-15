// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct FeatureShareHelper {
    
    func shareVote(
        on web3Feature: Web3Feature,
        presentingIn: UIViewController
    ) {
        
        let text = Localized("feature.vote.text", arg: "#" + web3Feature.hashTag) // eg: #WIP1001
        // TODO: @Annon to confirm final URL here
        let deepLinkURL = "https://www.sonsofcrypto/web3wallet?feature=\(web3Feature.hashTag)"
        let image = "overscroll_anon".assetImage!
        
        ShareFactoryHelper().share(
            items: [image, text, deepLinkURL],
            presentingIn: presentingIn
        )
        
    }
}
