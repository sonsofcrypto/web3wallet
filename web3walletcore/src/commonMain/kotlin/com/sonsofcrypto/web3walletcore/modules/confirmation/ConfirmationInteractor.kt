package com.sonsofcrypto.web3walletcore.modules.confirmation

import com.sonsofcrypto.web3lib.provider.model.TransactionResponse
import com.sonsofcrypto.web3lib.services.uniswap.UniswapService
import com.sonsofcrypto.web3lib.services.wallet.WalletService
import com.sonsofcrypto.web3lib.signer.contracts.CultGovernor
import com.sonsofcrypto.web3lib.signer.contracts.ERC721
import com.sonsofcrypto.web3lib.types.*
import com.sonsofcrypto.web3lib.types.Address.HexString
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3walletcore.services.nfts.NFTItem
import com.sonsofcrypto.web3walletcore.services.nfts.NFTsService

interface ConfirmationInteractor {
    @Throws(Throwable::class)
    suspend fun send(
        addressTo: String,
        network: Network,
        currency: Currency,
        amount: BigInt,
        networkFee: NetworkFee,
        password: String,
        salt: String,
    ): TransactionResponse

    @Throws(Throwable::class)
    suspend fun sendNFT(
        addressFrom: String,
        addressTo: String,
        network: Network,
        nft: NFTItem,
        password: String,
        salt: String,
    ): TransactionResponse

    @Throws(Throwable::class)
    suspend fun castVote(
        proposalId: String,
        support: Boolean,
        password: String,
        salt: String,
    ): TransactionResponse

    @Throws(Throwable::class)
    suspend fun executeSwap(
        network: Network,
        password: String,
        salt: String,
        swapService: UniswapService,
    ): TransactionResponse
}

class DefaultConfirmationInteractor(
    private val walletService: WalletService,
    private val nftsService: NFTsService,
): ConfirmationInteractor {

    @Throws(Throwable::class)
    override suspend fun send(
        addressTo: String,
        network: Network,
        currency: Currency,
        amount: BigInt,
        networkFee: NetworkFee,
        password: String,
        salt: String,
    ): TransactionResponse {
        walletService.unlock(password, salt, network)
        return walletService.transfer(addressTo, currency, amount, network)
    }

    @Throws(Throwable::class)
    override suspend fun sendNFT(
        addressFrom: String,
        addressTo: String,
        network: Network,
        nft: NFTItem,
        password: String,
        salt: String,
    ): TransactionResponse {
        walletService.unlock(password, salt, network)
        val contract = ERC721(HexString(nft.address))
        return walletService.contractSend(
            contract.address.hexString,
            contract.transferFrom(HexString(addressFrom), HexString(addressTo), nft.tokenId),
            network
        )
    }

    @Throws(Throwable::class)
    override suspend fun castVote(
        proposalId: String,
        support: Boolean,
        password: String,
        salt: String,
    ): TransactionResponse {
        // TODO: Review this when adding support to send a NFT on a different network than Ethereum.
        val network = Network.ethereum()
        walletService.unlock(password, salt, network)
        val contract = CultGovernor()
        return walletService.contractSend(
            contract.address.hexString,
            contract.castVote(proposalId.toUInt(), (if (support) 1 else 0).toUInt()),
            network
        )
    }

    @Throws(Throwable::class)
    override suspend fun executeSwap(
        network: Network,
        password: String,
        salt: String,
        swapService: UniswapService,
    ): TransactionResponse {
        walletService.unlock(password, salt, network)
        return swapService.executeSwap()
    }
}
