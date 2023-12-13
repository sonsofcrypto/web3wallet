package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.formatters.Formatters
import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Network

interface SignersInteractor {
    var selected: SignerStoreItem?
    var searchTerm: String?
    var showHidden: Boolean

    fun signer(idx: Int): SignerStoreItem
    fun indexOf(item: SignerStoreItem?): Int
    fun signersCount(): Int
    fun hiddenSignersCount(): Int

    fun name(idx: Int): String
    fun address(idx: Int, short: Boolean = false): String?
    fun isHidden(idx: Int): Boolean
    fun setHidden(hidden: Boolean, idx: Int)
    fun isMnemonicSigner(idx: Int): Boolean

    fun addAccount(item: SignerStoreItem, password: String, salt: String?)
    fun reorderSigner(fromIdx: Int, toIdx: Int)
}

class DefaultSignersInteractor(
    private var signerStoreService: SignerStoreService,
    private var networksService: NetworksService,
): SignersInteractor {
    override var selected: SignerStoreItem?
        get() = signerStoreService.selected
        set(value) {
            signerStoreService.selected = value
            if (value != null) networksService.signerStoreItem = value
        }
    override var searchTerm: String? = null
    override var showHidden: Boolean = false

    private val items: List<SignerStoreItem> get() = signerStoreService.items()

    override fun signer(idx: Int): SignerStoreItem =
        if (showHidden) items[idx] else items.filter { !it.isHidden() }[idx]

    override fun indexOf(item: SignerStoreItem?): Int =
        item?.let { items.indexOfFirst { it.uuid == item.uuid } } ?: -1

    override fun signersCount(): Int =
        if (showHidden) items.count() else items.count { !it.isHidden() }

    override fun hiddenSignersCount(): Int =
        items.count { it.isHidden() }

    override fun name(idx: Int): String =
        signer(idx).name

    override fun address(idx: Int, short: Boolean): String? {
        val item = signer(idx)
        val address = item.addresses[item.derivationPath]
        return if (!short) address
            else Formatters.address.format(address ?: "", 10, Network.ethereum())
    }

    override fun isHidden(idx: Int): Boolean =
        signer(idx).isHidden()

    override fun setHidden(hidden: Boolean, idx: Int) =
        signerStoreService.update(signer(idx).copy(hidden = hidden))

    override fun isMnemonicSigner(idx: Int): Boolean =
        signer(idx).type == SignerStoreItem.Type.MNEMONIC


    override fun addAccount(
        item: SignerStoreItem,
        password: String,
        salt: String?
    ) {
        signerStoreService.addAccount(
            item = item,
            password = password,
            salt = salt ?: "",
            hidden = false,
        )
    }

    override fun reorderSigner(fromIdx: Int, toIdx: Int) {
        signerStoreService.setSortOrder(signer(fromIdx), toIdx.toUInt())
    }
}
