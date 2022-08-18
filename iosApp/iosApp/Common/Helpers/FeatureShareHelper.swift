// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct FeatureShareHelper {
    
    func shareVote(
        on web3Feature: Web3Feature,
        presentingIn: UIViewController
    ) {
        
        let text = Localized(
            "feature.vote.text",
            arg: "#" + web3Feature.hashTag
        ).addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""
        
        guard let url = "https://www.twitter.com/intent/tweet?text=\(text)".url else { return }
        
        UIApplication.shared.open(url)
    }
}
