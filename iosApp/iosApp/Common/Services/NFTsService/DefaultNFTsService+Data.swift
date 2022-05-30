// Created by web3d4v on 27/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension DefaultNFTsService {
    
    static var yourNFTs: [NFTItem] = [
        .init(
            identifier: "web3wallet NFT #235",
            collectionIdentifier: "0-web3wallet NFT",
            name: "web3wallet NFT #235",
            ethPrice: 205,
            properties: [
                .init(
                    name: "BACKGROUND SUPER RARE",
                    value: "Miami Sunraise",
                    info: "0.45% have this trait"
                ),
                .init(
                    name: "MEME SUPER RARE",
                    value: "Trader",
                    info: "0.09% have this trait"
                ),
                .init(
                    name: "TICKET GOLD",
                    value: "Gold",
                    info: "0.45% have this trait"
                )

            ],
            image: "https://lh3.googleusercontent.com/JTGs-GC0aksoLct_7S_XL3OOSbU7RyA3IlcVUSWA7WgRXfMbqgvBLC-X6iYRg_bcYvodjf8p6pSKJPTAT-f_IrXLVr0kBvL9chpb=w600"
        ),
        .init(
            identifier: "web3wallet NFT #430",
            collectionIdentifier: "0-web3wallet NFT",
            name: "web3wallet NFT #430",
            ethPrice: 135,
            properties: [
                .init(
                    name: "BACKGROUND RARE",
                    value: "Miami Cold",
                    info: "0.09% have this trait"
                ),
                .init(
                    name: "MEME SILVER RARE",
                    value: "Ape",
                    info: "0.09% have this trait"
                ),
                .init(
                    name: "TICKET GOLD",
                    value: "Silver",
                    info: "0.9% have this trait"
                )

            ],
            image: "https://lh3.googleusercontent.com/CA-jhnnpaH54Lry85KULa22PwL_tCsxU6iRgFhnMTC1DvxGX680YzRES-590JD3aD9odGr81XBBMGoJ2G9YlrlEV41tnVXMmWpvE=w600"
        ),
        .init(
            identifier: "#53337",
            collectionIdentifier: "Otherdeed for Otherside",
            name: "#53337",
            ethPrice: 2.067,
            properties: [
                .init(name: "ARTIFACT?", value: "No", info: "79% have this trait"),
                .init(name: "CATEGORY", value: "Mineral", info: "12% have this trait"),
                .init(name: "ENVIRONMENT", value: "Crystal", info: "3% have this trait"),
                .init(name: "KODA?", value: "No", info: "90% have this trait"),
                .init(name: "SEDIMENT", value: "Infinite Expanse", info: "25% have this trait"),
                .init(name: "SOUTHERN RESOURCE", value: "Whisper", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/ee0c526768f4335501fa92bc89cf8e80.jpg?auto=format&w=600"
        ),
        .init(
            identifier: "#97097",
            collectionIdentifier: "Otherdeed for Otherside",
            name: "#97097",
            ethPrice: 2.367,
            properties: [
                .init(name: "ARTIFACT?", value: "No", info: "79% have this trait"),
                .init(name: "CATEGORY", value: "Harsh", info: "18% have this trait"),
                .init(name: "ENVIRONMENT", value: "Splinter", info: "5% have this trait"),
                .init(name: "KODA?", value: "No", info: "90% have this trait"),
                .init(name: "SEDIMENT", value: "Cosmic Dream", info: "23% have this trait")
            ],
            image: "https://img.seadn.io/files/e4e04f99b9d64d5629a6d49f57097152.jpg?auto=format&w=600"
        ),
        .init(
            identifier: "#50315",
            collectionIdentifier: "Otherdeed for Otherside",
            name: "#50315",
            ethPrice: 2.967,
            properties: [
                .init(name: "ARTIFACT?", value: "No", info: "79% have this trait"),
                .init(name: "CATEGORY", value: "Volcanic", info: "15% have this trait"),
                .init(name: "ENVIRONMENT", value: "Molten", info: "5% have this trait"),
                .init(name: "KODA?", value: "No", info: "90% have this trait"),
                .init(name: "SEDIMENT", value: "Infinite Expanse", info: "25% have this trait"),
                .init(name: "SOUTHERN RESOURCE", value: "Whisper", info: "3% have this trait"),
                .init(name: "WESTERN RESOURCE", value: "Moldium", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/a4cd8c953e4979e4cf0f9729c1ae61ef.jpg?auto=format&w=600"
        ),
        .init(
            identifier: "#73065",
            collectionIdentifier: "Otherdeed for Otherside",
            name: "#73065",
            ethPrice: 2.817,
            properties: [
                .init(name: "ARTIFACT?", value: "No", info: "79% have this trait"),
                .init(name: "CATEGORY", value: "Psychedelic", info: "9% have this trait"),
                .init(name: "ENVIRONMENT", value: "Mallow", info: "3% have this trait"),
                .init(name: "KODA?", value: "No", info: "90% have this trait"),
                .init(name: "SEDIMENT", value: "Rainbow Atmos", info: "22% have this trait"),
                .init(name: "NORTHEN RESOURCE", value: "Lumileaf", info: "3% have this trait"),
                .init(name: "EASTERN RESOURCE", value: "Runa", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/4e8d2a9aa9f08c62bf815738cac23d61.jpg?auto=format&w=600"
        ),
        .init(
            identifier: "goblintown #4768",
            collectionIdentifier: "goblintown.wtf",
            name: "goblintown #4768",
            ethPrice: 2.25,
            properties: [
                .init(name: "BODDE", value: "Wekkum Tarbys", info: "5% have this trait"),
                .init(name: "EERS", value: "Eirs", info: "6% have this trait"),
                .init(name: "EYE ON DAT SIDE", value: "Narf", info: "4% have this trait"),
                .init(name: "EYZ ON DIS SIDE", value: "O Noooooo", info: "4% have this trait"),
                .init(name: "HEDZ", value: "Jawboymangirl", info: "6% have this trait"),
                .init(name: "MUNCHYHOLE", value: "Glibbaglab", info: "5% have this trait"),
                .init(name: "COLLRZED", value: "Bloody Milk Yumm", info: "7% have this trait"),
                .init(name: "STANKFINDER", value: "Kwaigun", info: "4% have this trait")
            ],
            image: "https://lh3.googleusercontent.com/svfh_JbuWEnn7ghVrDHJZGl91yv7C5gfMEYE17eDCB48K23q8wNq8eAKvnPVxNgB9SADe_fmASj8Uhk5ZyZ2Yy5JOx04xCBqG7tPcow=w600"
        ),
        .init(
            identifier: "#8520",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#8520",
            ethPrice: 60,
            properties: [
                .init(name: "BACKGROUND", value: "Gray", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Prom Dress", info: "1% have this trait"),
                .init(name: "EYES", value: "Bored", info: "17% have this trait"),
                .init(name: "FUR", value: "Black", info: "12% have this trait"),
                .init(name: "HAT", value: "Sea Captain's Hat", info: "3% have this trait"),
                .init(name: "MOUTH", value: "Phoneme Oh", info: "2% have this trait")
            ],
            image: "https://img.seadn.io/files/ed1409d2d2008aa99ac77a97050be6f7.png?auto=format&w=600"
        ),
        .init(
            identifier: "web3wallet NFT #1038",
            collectionIdentifier: "0-web3wallet NFT",
            name: "web3wallet NFT #1038",
            ethPrice: 105,
            properties: [
                .init(
                    name: "BACKGROUND BRONZE",
                    value: "Bubble Warm",
                    info: "1% have this trait"
                ),
                .init(
                    name: "MEME RARE",
                    value: "Wojak Carlos Matos",
                    info: "0.18% have this trait"
                ),
                .init(
                    name: "TICKET BRONZE",
                    value: "Bronze",
                    info: "2% have this trait"
                )

            ],
            image: "https://lh3.googleusercontent.com/f6J-Fe4sJHC37M3mbJT3RmIBG_DqFZi_HZzRwIAdUbQdvqbq-oPkLTA88WrTaU39Ur2_tq9QAQ9smwZVEhMoXaZvSHbRtG52mH1TwQ=w600"
        ),
        .init(
            identifier: "#3368",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#3368",
            ethPrice: 77.489,
            properties: [
                .init(name: "BACKGROUND", value: "Orange", info: "13% have this trait"),
                .init(name: "EYES", value: "Angry", info: "4% have this trait"),
                .init(name: "FUR", value: "Red", info: "5% have this trait"),
                .init(name: "HAT", value: "Iris Boho", info: "2% have this trait"),
                .init(name: "MOUTH", value: "Grin", info: "7% have this trait")
            ],
            image: "https://img.seadn.io/files/23849c1670acb9074d937496770589bf.png?auto=format&w=600"
        ),
        .init(
            identifier: "Chimpers #2501",
            collectionIdentifier: "Chimpers",
            name: "Chimpers #2501",
            ethPrice: 1.489,
            properties: [
                .init(name: "BACK", value: "Dragonslayer Blade", info: "2% have this trait"),
                .init(name: "BACKGROUND", value: "Papaya Orange", info: "22% have this trait"),
                .init(name: "EYES", value: "Chimped", info: "9% have this trait"),
                .init(name: "FACE EXTRA", value: "Slurping Ramen", info: "3% have this trait"),
                .init(name: "HEAD", value: "Displayoooor", info: "2% have this trait"),
                .init(name: "TYPE", value: "Jet Black", info: "13% have this trait")
            ],
            image: "https://lh3.googleusercontent.com/-TlKWOTfpKzSkaJ6G0I0NlkZozmumRroslqCDeeN-6vQpPq2qGnAY6NM077nPmEhM01lhSvIGlCYJ_ExaVwo4w2O1PJ2KcAplw5kOg=w600"
        ),
        .init(
            identifier: "Chimpers #4799",
            collectionIdentifier: "Chimpers",
            name: "Chimpers #4799",
            ethPrice: 1.79,
            properties: [
                .init(name: "BACK", value: "Fishing Rod", info: "7% have this trait"),
                .init(name: "BACKGROUND", value: "Breezy Blue", info: "21% have this trait"),
                .init(name: "EYES", value: "Intense", info: "9% have this trait"),
                .init(name: "FACE EXTRA", value: "Poker Face", info: "6% have this trait"),
                .init(name: "HEAD", value: "Pink Yukata", info: "1% have this trait"),
                .init(name: "TYPE", value: "Jet Black", info: "13% have this trait")
            ],
            image: "https://lh3.googleusercontent.com/mDsLPsUjF8dvyX5-41oPFBLO0WjoGHqevseNtx0CyitVW9aCXc7EZ7kvFHBwOMWZjb9g_5zPd2rBt5iJ_Vaip-FR2WiC7UMDwloxPQk=w600"
        ),
        .init(
            identifier: "Chimpers #5440",
            collectionIdentifier: "Chimpers",
            name: "Chimpers #5440",
            ethPrice: 1.9,
            properties: [
                .init(name: "BACK", value: "Guiding Lanterns", info: "7% have this trait"),
                .init(name: "BACKGROUND", value: "Breezy Blue", info: "21% have this trait"),
                .init(name: "EYES", value: "Hip Specs", info: "3% have this trait"),
                .init(name: "FACE EXTRA", value: "Slurping Ramen", info: "3% have this trait"),
                .init(name: "HEAD", value: "Tactical Flack", info: "3% have this trait"),
                .init(name: "TYPE", value: "Charcoal Grey", info: "14% have this trait")
            ],
            image: "https://lh3.googleusercontent.com/vDygHcaFgqCggQiS8GzhnRgVSnVvqSIL5pTvm4qg4hxUjswujDc1o8wrdQqFiPVQUVN3ywU2bDCybMfsXjAgjYg9cB70SRiIzQJOmg=w600"
        ),
        .init(
            identifier: "#3929",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#3929",
            ethPrice: 88.8284,
            properties: [
                .init(name: "BACKGROUND", value: "Purple", info: "13% have this trait"),
                .init(name: "CLOTHES", value: "Tanktop", info: "2% have this trait"),
                .init(name: "EARRING", value: "Silver Hoop", info: "9% have this trait"),
                .init(name: "EYES", value: "Crazy", info: "4% have this trait"),
                .init(name: "FUR", value: "Black", info: "12% have this trait"),
                .init(name: "MOUTH", value: "Bored", info: "23% have this trait")
            ],
            image: "https://img.seadn.io/files/75ba6c7d2c438146d7fe16a15de637a6.png?auto=format&w=600"
        ),
        .init(
            identifier: "#687",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#687",
            ethPrice: 89.84,
            properties: [
                .init(name: "BACKGROUND", value: "Aquamarine", info: "13% have this trait"),
                .init(name: "CLOTHES", value: "Leather Jacket", info: "2% have this trait"),
                .init(name: "EYES", value: "Bored", info: "17% have this trait"),
                .init(name: "FUR", value: "Cream", info: "6% have this trait"),
                .init(name: "HAT", value: "Party Hat 2", info: "1% have this trait"),
                .init(name: "MOUTH", value: "Range", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/9899601221545c51ba4a8027838917d2.png?auto=format&w=600"
        ),
        .init(
            identifier: "#2901",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#2901",
            ethPrice: 90,
            properties: [
                .init(name: "BACKGROUND", value: "New Punk Blue", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Puffy Vest", info: "2% have this trait"),
                .init(name: "EYES", value: "Bored", info: "17% have this trait"),
                .init(name: "FUR", value: "Tan", info: "6% have this trait"),
                .init(name: "HAT", value: "Horns", info: "3% have this trait"),
                .init(name: "MOUTH", value: "Bored Cigarette", info: "7% have this trait")
            ],
            image: "https://img.seadn.io/files/29c51f819d999d8552616b6c9a7e56f4.png?auto=format&w=600"
        ),
        .init(
            identifier: "#7987",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#7987",
            ethPrice: 88,
            properties: [
                .init(name: "BACKGROUND", value: "Gray", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Prison Jumpsuit", info: "2% have this trait"),
                .init(name: "EYES", value: "Wide Eyed", info: "5% have this trait"),
                .init(name: "FUR", value: "Zombie", info: "3% have this trait"),
                .init(name: "HAT", value: "Beanie", info: "6% have this trait"),
                .init(name: "MOUTH", value: "Jovial", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/d7caf07b5b8fee893b0a7da6c2cf61e7.png?auto=format&w=600"
        ),
        .init(
            identifier: "#7151",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#7151",
            ethPrice: 91,
            properties: [
                .init(name: "BACKGROUND", value: "Army Green", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Work Vest", info: "2% have this trait"),
                .init(name: "EYES", value: "Bloodshot", info: "8% have this trait"),
                .init(name: "FUR", value: "Black", info: "12% have this trait"),
                .init(name: "HAT", value: "Police Motorcycle", info: "1% have this trait"),
                .init(name: "MOUTH", value: "Bored Unshaven", info: "16% have this trait")
            ],
            image: "https://img.seadn.io/files/2ffba2a6a7f7a6d9a1204789031f55e3.png?auto=format&w=600"
        ),
        .init(
            identifier: "#1004",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#1004",
            ethPrice: 90,
            properties: [
                .init(name: "BACKGROUND", value: "Purple", info: "13% have this trait"),
                .init(name: "CLOTHES", value: "Sailor Shirt", info: "3% have this trait"),
                .init(name: "EARRING", value: "Silver Stud", info: "8% have this trait"),
                .init(name: "EYES", value: "Wide Eyed", info: "5% have this trait"),
                .init(name: "FUR", value: "Black", info: "12% have this trait"),
                .init(name: "HAT", value: "Halo", info: "3% have this trait"),
                .init(name: "MOUTH", value: "Small Grin", info: "3% have this trait")
            ],
            image: "https://img.seadn.io/files/66f56d7caa89cd7baadf552598e5db06.png?auto=format&w=600"
        ),
        .init(
            identifier: "#3735",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#3735",
            ethPrice: 92,
            properties: [
                .init(name: "BACKGROUND", value: "New Punk Blue", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Stripe Tee", info: "4% have this trait"),
                .init(name: "EYES", value: "3d", info: "5% have this trait"),
                .init(name: "FUR", value: "Dmt", info: "2% have this trait"),
                .init(name: "MOUTH", value: "Bored", info: "23% have this trait")
            ],
            image: "https://img.seadn.io/files/3f1560bfb0bed4749d4dd73c772f1568.png?auto=format&w=600"
        ),
        .init(
            identifier: "#2157",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#2157",
            ethPrice: 96,
            properties: [
                .init(name: "BACKGROUND", value: "Gray", info: "12% have this trait"),
                .init(name: "CLOTHES", value: "Blue Dress", info: "0.95% have this trait"),
                .init(name: "EYES", value: "Angry", info: "4% have this trait"),
                .init(name: "FUR", value: "Dark Brown", info: "14% have this trait"),
                .init(name: "HAT", value: "Spinner Hat", info: "2% have this trait"),
                .init(name: "MOUTH", value: "Tongue Out", info: "2% have this trait")
            ],
            image: "https://img.seadn.io/files/d3f335f03c62b8806e67158c4c34da98.png?auto=format&w=600"
        ),
        .init(
            identifier: "#648",
            collectionIdentifier: "Bored Ape Yacht Club",
            name: "#648",
            ethPrice: 18800,
            properties: [
                .init(name: "BACKGROUND", value: "Aquamarine", info: "13% have this trait"),
                .init(name: "CLOTHES", value: "Hip Hop", info: "0.95% have this trait"),
                .init(name: "EYES", value: "Heart", info: "4% have this trait"),
                .init(name: "FUR", value: "Dmt", info: "14% have this trait"),
                .init(name: "HAT", value: "Sea Captain's Hat", info: "3% have this trait"),
                .init(name: "MOUTH", value: "Bored Unshaven", info: "16% have this trait")
            ],
            image: "https://img.seadn.io/files/0ffd18a26fa50f91281fb7c3484cefb1.png?auto=format&w=600"
        )
    ]
    
    static var yourNFTCollections: [NFTCollection] = [
        .init(
            identifier: "0-web3wallet NFT",
            coverImage: "https://lh3.googleusercontent.com/kyXGLXtZYoEfGcVTPOKxNW8nA0czplTHNQ7b0XVnMjBJgzSAf7smsZFYkL3_gx4qFEuXGOjRWA2j-VIYOHsMMkTj8GKHRz5yqu-V=h600",
            title: "web3wallet NFT",
            author: "sonsOfCrypto",
            isVerifiedAccount: false,
            authorImage: "https://lh3.googleusercontent.com/m70On7uQnRMx_MXK8WcCJe3Rl2CtOkIOigyyqRzMBPP-9HCUXlOar1P16Rr5uCz0V7hKG8xlqfKXk7wGgIF3mfQNfHit4BI5fJp5_RA=s130",
            description: "web3wallet OGs club, soc gang! Ones who has been with us from day one! 😍"
        ),
        .init(
            identifier: "Otherdeed for Otherside",
            coverImage: "https://lh3.googleusercontent.com/E_XVuM8mX1RuqBym2JEX4RBg_sj9KbTFBAi0qU4eBr2E3VCC0bwpWrgHqBOaWsKGTf4-DBseuZJGvsCVBnzLjxqgq7rAb_93zkZ-=h600",
            title: "Otherdeed for Otherside",
            author: "OthersideMeta",
            isVerifiedAccount: true,
            authorImage: "https://lh3.googleusercontent.com/yIm-M5-BpSDdTEIJRt5D6xphizhIdozXjqSITgK4phWq7MmAU3qE7Nw7POGCiPGyhtJ3ZFP8iJ29TFl-RLcGBWX5qI4-ZcnCPcsY4zI=s130",
            description: "Otherdeed is the key to claiming land in Otherside. Each have a unique blend of environment and sediment — some with resources, some home to powerful artifacts. And on a very few, a Koda roams."
        ),
        .init(
            identifier: "Chimpers",
            coverImage: "https://lh3.googleusercontent.com/ej5o0pXCsgOszX-yka3G79k-bQQeLHcHA2ykY34U7T1P-uHeyFE4bLG9r3c-ic2VKH3DTL0-K62lWkUXuCSjpY_C90j6Gs32fq39eg=h200",
            title: "Chimpers",
            author: "TimpersVault",
            isVerifiedAccount: true,
            authorImage: "https://lh3.googleusercontent.com/lkvZo5xkyjuvJ25mJ_3kCqZXy6jPGoOEsTvhpOrfMa-ybUvY4tmR22ih5JbiZF9g8IKQ5-ePC-HDvUZKbnwFIuiplO6_7Vxz0OmB=s130",
            description: "Chimpers are a collection of 5,555 generative NFT pixel characters created by @TimpersHD. Chimpers are your digital identity for the Chimpverse and your passport to adventure. !CHIMP"
        ),
        .init(
            identifier: "Bored Ape Yacht Club",
            coverImage: "https://lh3.googleusercontent.com/RBX3jwgykdaQO3rjTcKNf5OVwdukKO46oOAV3zZeiaMb8VER6cKxPDTdGZQdfWcDou75A8KtVZWM_fEnHG4d4q6Um8MeZIlw79BpWPA=h200",
            title: "Bored Ape Yacht Club",
            author: "BoredApeYachtClub",
            isVerifiedAccount: true,
            authorImage: "https://lh3.googleusercontent.com/Ju9CkWtV-1Okvf45wo8UctR-M9He2PjILP0oOvxE89AyiPPGtrR3gysu1Zgy0hjd2xKIgjJJtWIc0ybj4Vd7wv8t3pxDGHoJBzDB=s130",
            description: "The Bored Ape Yacht Club is a collection of 10,000 unique Bored Ape NFTs— unique digital collectibles living on the Ethereum blockchain. Your Bored Ape doubles as your Yacht Club membership card, and grants access to members-only benefits, the first of which is access to THE BATHROOM, a collaborative graffiti board. Future areas and perks can be unlocked by the community through roadmap activation. Visit www.BoredApeYachtClub.com for more details."
        ),
        .init(
            identifier: "goblintown.wtf",
            coverImage: "https://lh3.googleusercontent.com/cb_wdEAmvry_noTfeuQzhqKpghhZWQ_sEhuGS9swM03UM8QMEVJrndu0ZRdLFgGVqEPeCUzOHGTUllxug9U3xdvt0bES6VFdkRCKPqg=h200",
            title: "goblintown.wtf",
            author: "kingofthegoblin",
            isVerifiedAccount: true,
            authorImage: "https://lh3.googleusercontent.com/cb_wdEAmvry_noTfeuQzhqKpghhZWQ_sEhuGS9swM03UM8QMEVJrndu0ZRdLFgGVqEPeCUzOHGTUllxug9U3xdvt0bES6VFdkRCKPqg=s130",
            description: "AAAAAAAUUUUUGGGHHHHH gobblins goblinns GOBLINNNNNNNNns wekm ta goblintown yoo sniksnakr DEJEN RATS oooooh rats are yummmz dis a NEFTEEE O GOBBLINGS on da BLOKCHIN wat? oh. crustybutt da goblinking say GEE EMMM DEDJEN RUTS an queenie saay HLLO SWEATIES ok dats all byeby"
        )
    ]
    
}
