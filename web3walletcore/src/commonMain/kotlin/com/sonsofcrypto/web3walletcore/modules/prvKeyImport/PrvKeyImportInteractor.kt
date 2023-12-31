package com.sonsofcrypto.web3walletcore.modules.prvKeyImport

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.PrvKeySignerConfig
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.utils.decodeBase58WithChecksum
import com.sonsofcrypto.web3lib.utils.defaultDerivationPath
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.isValidHexString
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.extensions.trimHexPrefix
import com.sonsofcrypto.web3lib.utils.lastDerivationPathComponent
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.prvKeyImport.PrvKeyImportError.INVALID_PRV_KEY
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService
import com.sonsofcrypto.web3walletcore.services.settings.SettingsService

enum class PrvKeyImportError { NOT_HEX_DIGIT, INVALID_PRV_KEY }

interface PrvKeyImportInteractor {
    var keyInput: String?
    var name: String
    var iCloudSecretStorage: Boolean
    var passwordType: SignerStoreItem.PasswordType
    var password: String
    var passUnlockWithBio: Boolean
    var showHidden: Boolean

    fun prvKey(): String
    fun isPrvKeyValid(): Boolean
    fun prvKeyError(): PrvKeyImportError?
    fun passError(password: String, type: SignerStoreItem.PasswordType): String?

    fun createPrvKeySigner(): SignerStoreItem
    fun generateDefaultNameIfNeeded()
    fun generatePassword(): String
    fun pasteToClipboard(text: String)

    @Throws(Exception::class)
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

class DefaultPrvKeyImportInteractor(
    private val signerStoreService: SignerStoreService,
    private val passwordService: PasswordService,
    private val addressService: AddressService,
    private val clipboardService: ClipboardService,
    private val settingsService: SettingsService,
): PrvKeyImportInteractor {
    private var accounts: MutableList<Account> = mutableListOf(
        Account("", "", "", false)
    )

    override var keyInput: String? = ""
        set(value) { field = value; keyInputDidChange(value ?: "") }

    override var name: String = ""
        get() { return accountName(0) }
        set(value) { field = value; setAccountName(value, 0); }

    override var iCloudSecretStorage: Boolean = false
    override var passwordType: SignerStoreItem.PasswordType = BIO
    override var password: String = ""
    override var passUnlockWithBio: Boolean = true
    override var showHidden: Boolean = false

    private fun keyInputDidChange(keyInput: String) =
        if (isPrvKeyValid()) regenerateAccountsAndAddresses() else Unit

    override fun prvKey(): String =
        keyInput?.trim()?.trimHexPrefix() ?: ""

    private fun prvKeyBytes(): ByteArray = when (prvKey().length) {
        64 -> prvKey().hexStringToByteArray()
        111 -> prvKey().decodeBase58WithChecksum().takeLast(32).toByteArray()
        else -> ByteArray(0)
    }

    override fun isPrvKeyValid(): Boolean =
        if (prvKey().length < 16) false
        else prvKeyError() == null

    override fun prvKeyError(): PrvKeyImportError? {
        val key = prvKey().lowercase()
        if (key.length < 3)
            return null
        if (key.substring(0, 4) != "xprv" && !key.isValidHexString(true))
            return PrvKeyImportError.NOT_HEX_DIGIT
        if (key.length == 111 && key.length == 64)
            try {
                addressService.addressFromPrivKeyBytes(prvKeyBytes())
            } catch (err: Throwable) {
                return INVALID_PRV_KEY
            }
        return null
    }

    override fun passError(
        pass: String,
        type: SignerStoreItem.PasswordType
    ): String? = passwordService.validationError(pass, type)

    override fun createPrvKeySigner(): SignerStoreItem {
        val cnf = PrvKeySignerConfig(
            prvKeyBytes().toHexString(), name, passUnlockWithBio,
            iCloudSecretStorage, passwordType,
        )
        return signerStoreService.createPrivKeySigner(cnf, password)
    }

    override fun generateDefaultNameIfNeeded() = if (name.isEmpty()) {
        name = Localized("mnemonic.defaultWalletName")
        val mnemonicsCnt = signerStoreService.mnemonicSignerItems().count()
        if (mnemonicsCnt > 0) name = "$name $mnemonicsCnt" else Unit
    } else Unit

    override fun generatePassword(): String =
        secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) =
        clipboardService.paste(text)

    override fun accountName(idx: Int): String =
        account(idx).name

    override fun accountDerivationPath(idx: Int): String =
        account(idx).derivationPath

    override fun accountAddress(idx: Int): String =
        account(idx).address

    override fun accountPrivKey(idx: Int, xprv: Boolean): String {
        return prvKey()
    }

    override fun accountIsHidden(idx: Int): Boolean =
        account(idx).isHidden

    override fun absoluteAccountIdx(idx: Int): Int =
        lastDerivationPathComponent(account(idx).derivationPath)

    override fun setAccountName(name: String, idx: Int) {
        account(idx).name = name
    }

    override fun setAccountHidden(hidden: Boolean, idx: Int) {
        account(idx).isHidden = hidden
    }

    override fun accountsCount(): Int =
        if (showHidden) accounts.count() else visibleAccounts().count()

    override fun hiddenAccountsCount(): Int =
        accounts.count { it.isHidden }

    override fun globalExpertMode(): Boolean =
        settingsService.expertMode

    private fun regenerateAccountsAndAddresses() {
        if (!isPrvKeyValid()) return;
        val keyBytes = prvKey().hexStringToByteArray()
        accounts.forEachIndexed { idx, acc ->
            acc.address = addressService.addressFromPrivKeyBytes(keyBytes)
        }
    }

    private fun account(idx: Int): Account =
        if (showHidden) accounts[idx] else visibleAccounts()[idx]

    private fun visibleAccounts(): List<Account> =
        accounts.filter { !it.isHidden }
}

private class Account(
    var name: String = "",
    var derivationPath: String = "",
    var address: String = "",
    var isHidden: Boolean = false
)
