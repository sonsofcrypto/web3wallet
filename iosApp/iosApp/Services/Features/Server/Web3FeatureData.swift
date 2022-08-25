// Created by web3d4v on 15/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct Web3FeatureData: Equatable {
    
    let id: String
    let title: String
    let body: String
    let imageUrl: String // URL pointing to a valid image in imgur, eg: https://imgur.com/gallery/XXXXX
    let category: Web3Feature.Category
    let creationDate: String // UTC time for when we should start searching for votes
}

extension Web3FeatureData {
    
    var hashTag: String {

        "#\(Localized("feature.hashTag", arg: id))"
    }
    
    static var allFeatures: [Web3FeatureData] {
        
        [
            .init(
                id: "1001",
                title: "ETH 2.0 support",
                body: "Add support for ETH 2.0 light client. (Geth & Prysm)",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/1001.png",
                category: .infrastructure,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "1002",
                title: "Wallet connect support",
                body: "WalletConnect is an open protocol to communicate securely between Wallets and Dapps (Web3 Apps). The protocol establishes a remote connection between two apps and/or devices using a Bridge server to relay payloads. These payloads are symmetrically encrypted through a shared key between the two peers. The connection is initiated by one peer displaying a QR Code or deep link with a standard WalletConnect URI and is established when the counter-party approves this connection request. It also includes an optional Push server to allow Native applications to notify the user of incoming payloads for established connections.",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/1002.png",
                category: .infrastructure,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "2001",
                title: "ENS integration",
                body: "Introduction\nThe Ethereum Name Service (ENS) is a distributed, open, and extensible naming system based on the Ethereum blockchain.\nENS’s job is to map human-readable names like ‘alice.eth’ to machine-readable identifiers such as Ethereum addresses, other cryptocurrency addresses, content hashes, and metadata. ENS also supports ‘reverse resolution’, making it possible to associate metadata such as canonical names or interface descriptions with Ethereum addresses.\nENS has similar goals to DNS, the Internet’s Domain Name Service, but has significantly different architecture due to the capabilities and constraints provided by the Ethereum blockchain. Like DNS, ENS operates on a system of dot-separated hierarchical names called domains, with the owner of a domain having full control over subdomains.\nTop-level domains, like ‘.eth’ and ‘.test’, are owned by smart contracts called registrars, which specify rules governing the allocation of their subdomains. Anyone may, by following the rules imposed by these registrar contracts, obtain ownership of a domain for their own use. ENS also supports importing in DNS names already owned by the user for use on ENS.\nBecause of the hierarchal nature of ENS, anyone who owns a domain at any level may configure subdomains - for themselves or others - as desired. For instance, if Alice owns 'alice.eth', she can create 'pay.alice.eth' and configure it as she wishes.\nENS is deployed on the Ethereum main network and on several test networks. If you use a library such as the  Javascript library, or an end-user application, it will automatically detect the network you are interacting with and use the ENS deployment on that network.\nYou can try ENS out for yourself now by using the , or by using any of the many ENS enabled applications on .",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/2001.png",
                category: .integrations,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "2002",
                title: "Polygon support",
                body: "Polygon is a scaling solution for public blockchains. Polygon PoS supports all the existing Ethereum tooling along with faster and cheaper transactions. Think of a Sidechain as a clone of a 'parent' blockchain, supporting transfer of assets to and from the main chain. It is simply an alternate to parent chain that creates a new blockchain with its own mechanism of creating blocks (consensus mechanism). Connecting a sidechain to a parent chain involves setting up a method of moving assets between the chains.",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/2002.png",
                category: .integrations,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "3001",
                title: "Group wallets",
                body: "Add ability to group wallets on wallet screen",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/3001.png",
                category: .features,
                creationDate: "2022-08-18T00:00:00.000Z"
            ),
            .init(
                id: "3002",
                title: "NFT multi send",
                body: "Add support for sending multiple NFTs in one transaction",
                imageUrl: "https://raw.githubusercontent.com/sonsofcrypto/web3wallet-improvement-proposals/master/images/3002.png",
                category: .features,
                creationDate: "2022-08-18T00:00:00.000Z"
            )
        ]
    }
}
