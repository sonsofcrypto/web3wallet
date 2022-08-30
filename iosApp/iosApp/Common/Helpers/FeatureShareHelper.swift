// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct FeatureShareHelper {
    
    func shareVote(
        on web3Feature: Web3Feature,
        presentingIn: UIViewController
    ) {
        let text = String(
            format: Localized("feature.vote.text"),
            web3Feature.id,
            web3Feature.title
        )

        let imgUrlStr = "https://sonsofcrypto.com/web3wallet-improvement-proposals/\(web3Feature.id).html"

        let textEncoded = text.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""

        let urlEncoded = imgUrlStr.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""

        guard let url = "https://www.twitter.com/intent/tweet?text=\(textEncoded)&url=\(urlEncoded)".url else { return }
        
        UIApplication.shared.open(url)
    }
}
