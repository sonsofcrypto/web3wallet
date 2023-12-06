package com.sonsofcrypto.web3walletcore.modules.mnemonicUpdate

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.SecretStorage
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.lastDerivationPathComponent
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

interface MnemonicUpdateInteractor {
    var name: String
    var salt: String
    var iCloudSecretStorage: Boolean
    var showHidden: Boolean

    @Throws(SecretStorage.Error::class)
    fun setup(signerStoreItem: SignerStoreItem, password: String, salt: String)
    fun mnemonic(): String
    fun pasteToClipboard(text: String)
    fun update(): SignerStoreItem?
    fun delete()

    @Throws(Exception::class)
    fun addAccount(derivationPath: String? = null)
    fun accountName(idx: Int): String
    fun accountDerivationPath(idx: Int): String
    fun accountAddress(idx: Int): String
    /** if xprv is false returns prv key hex string else xprv hex string */
    fun accountPrivKey(idx: Int, xprv: Boolean = false): String
    fun accountIsHidden(idx: Int): Boolean
    fun absoluteAccountIdx(idx: Int): Int
    fun setAccountName(name: String, idx: Int)
    fun setAccountHidden(hidden: Boolean, idx: Int)
    fun accountsCount(): Int
    fun hiddenAccountsCount(): Int
    fun globalExpertMode(): Boolean
}

class DefaultMnemonicUpdateInteractor(
    private val signerStoreService: SignerStoreService,
    private val addressService: AddressService,
    private val clipboardService: ClipboardService,
    private val settingsService: SettingsService,
): MnemonicUpdateInteractor {
    private var signerStoreItem: SignerStoreItem? = null
    private var mnemonic: String = ""
    private var password: String = ""
    private var accounts: MutableList<Account> = mutableListOf(
        Account("Zero", "M/64/0/0/0", "0x3565b665a433978c3c6a1d85343a9607dcce4e2e", false),
        Account("One", "M/64/0/0/1", "0x3565b665a433978c3c6a1d85343a9607dcce4e2e", true),
        Account("Two", "M/64/0/0/2", "0x3565b665a433978c3c6a1d85343a9607dcce4e2e", false),
    )

    override var name: String
        get() { return accountName(0) }
        set(value) { setAccountName(value, 0); }

    override var salt: String = ""
    override var iCloudSecretStorage: Boolean = false
    override var showHidden: Boolean = false

    @Throws(SecretStorage.Error::class)
    override fun setup(
        signerStoreItem: SignerStoreItem,
        password: String,
        salt: String
    ) {
        this.password = password
        this.salt = salt
        this.signerStoreItem = signerStoreItem
        this.name = signerStoreItem.name
        this.iCloudSecretStorage = signerStoreItem.iCloudSecretStorage
        val result = signerStoreService.secretStorage(signerStoreItem, password)
            ?.decrypt(password)
        mnemonic = result?.mnemonic ?: ""
    }

    override fun mnemonic(): String = mnemonic

    override fun update(): SignerStoreItem? {
        if (signerStoreItem == null) return null
        val secretStorage = signerStoreService.secretStorage(
            signerStoreItem!!,
            password
        ) ?: return null
        val item = signerStoreItem!!.copy(
            name = name,
            iCloudSecretStorage = iCloudSecretStorage
        )
        signerStoreService.add(item, password, secretStorage)
        return item
    }

    override fun delete() {
        if (signerStoreItem!!.uuid == signerStoreService.selected?.uuid) {
            signerStoreService.remove(signerStoreItem!!)
            signerStoreService.selected = signerStoreService.items().firstOrNull()
        } else {
            signerStoreService.remove(signerStoreItem!!)
        }
    }

    override fun pasteToClipboard(text: String) = clipboardService.paste(text)

    @Throws(Exception::class)
    override fun addAccount(derivationPath: String?) {
        println("[MnemonicUpdateInteractor] addAccount")
        // TODO("Implement")
    }

    override fun accountName(idx: Int): String = account(idx).name

    override fun accountDerivationPath(idx: Int): String = account(idx)
        .derivationPath

    override fun accountAddress(idx: Int): String = account(idx).address

    override fun accountPrivKey(idx: Int, xprv: Boolean): String {
//        val key = bip44.deriveChildKey(accountDerivationPath(idx))
//        return if (xprv) key.base58WithChecksumString()
//        else key.key.toHexString(false)
        // TODO("Implement")
        return "Priv key"
    }

    override fun accountIsHidden(idx: Int): Boolean = account(idx).isHidden

    override fun absoluteAccountIdx(idx: Int): Int
            = lastDerivationPathComponent(account(idx).derivationPath)

    override fun setAccountName(name: String, idx: Int) {
        account(idx).name = name
    }

    override fun setAccountHidden(hidden: Boolean, idx: Int) {
        account(idx).isHidden = hidden
    }

    override fun accountsCount(): Int  = if (showHidden) accounts.count()
    else visibleAccounts().count()

    override fun hiddenAccountsCount(): Int = accounts.count { it.isHidden }

    override fun globalExpertMode(): Boolean = settingsService.expertMode

    private fun account(idx: Int): Account = if (showHidden) accounts[idx]
        else visibleAccounts()[idx]

    private fun visibleAccounts(): List<Account> = accounts.filter { !it.isHidden }
}

private class Account(
    var name: String = "",
    var derivationPath: String = "",
    var address: String = "",
    var isHidden: Boolean = false
)