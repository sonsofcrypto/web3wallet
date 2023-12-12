package com.sonsofcrypto.web3walletcore.modules.signers

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService

interface SignersInteractor {
    var selected: SignerStoreItem?
    var searchTerm: String?
    var showHidden: Boolean

    fun signer(idx: Int): SignerStoreItem
    fun indexOf(item: SignerStoreItem?): Int
    fun signersCount(): Int
    fun hiddenSignersCount(): Int

    fun name(idx: Int): String
    fun address(idx: Int, short: Boolean = false): String
    fun isHidden(idx: Int): Boolean
    fun setHidden(hidden: Boolean, idx: Int)
    fun isMnemonicSigner(idx: Int): Boolean

    fun addAccount(item: SignerStoreItem, password: String, salt: String?)
    fun reorderSigner(fromIdx: Int, toIdx: Int)

    fun invalidateCaches()
}

class DefaultSignersInteractor(
    private var signerStoreService: SignerStoreService,
    private var networksService: NetworksService,
    private var address: AddressService,
): SignersInteractor {
    override var selected: SignerStoreItem?
        get() = signerStoreService.selected
        set(value) {
            signerStoreService.selected = value
            if (value != null) networksService.signerStoreItem = value
        }
    override var searchTerm: String? = null
    override var showHidden: Boolean = false

    private var items: List<SignerStoreItem> = signerStoreService.items()


    override fun isMnemonicSigner(idx: Int): Boolean {
        signer(idx).type != SignerStoreItem.Type.MNEMONIC
    }

    override fun indexOf(item: SignerStoreItem): Int {
        return items.indexOfFirst { it.uuid == item.uuid }
    }

    override fun invalidateCaches() {
        items = signerStoreService.items()
    }
}
