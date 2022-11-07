package com.sonsofcrypto.web3walletcore.modules.nftDetail

import com.sonsofcrypto.web3walletcore.services.nfts.NFTCollection
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem

data class NFTDetailViewModel(
    val nft: NFTItem,
    val collection: NFTCollection,
)