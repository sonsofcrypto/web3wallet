package com.sonsofcrypto.web3walletcore.modules.nftsCollection

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

data class NFTsCollectionViewModel(
    val collection: NFTCollection,
    val nfts: List<NFTItem>,
)
