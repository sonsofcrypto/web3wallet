package com.sonsofcrypto.web3walletcore.modules.mnemonicNew

import com.sonsofcrypto.web3lib.services.address.AddressService
import com.sonsofcrypto.web3lib.services.keyStore.MnemonicSignerConfig
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.Bip39.EntropySize.ES128
import com.sonsofcrypto.web3lib.utils.defaultDerivationPath
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import com.sonsofcrypto.web3lib.utils.incrementedDerivationPath
import com.sonsofcrypto.web3lib.utils.secureRand
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.services.clipboard.ClipboardService
import com.sonsofcrypto.web3walletcore.services.password.PasswordService

interface MnemonicNewInteractor {
    var name: String
    var salt: String
    var saltMnemonicOn: Boolean
    var entropySize: Bip39.EntropySize
    var iCloudSecretStorage: Boolean
    var passwordType: SignerStoreItem.PasswordType
    var password: String
    var passUnlockWithBio: Boolean

    fun mnemonic(): String
    @Throws(Exception::class)
    fun createMnemonicSigner(): SignerStoreItem
    fun regenerateMnemonic()
    fun generateDefaultNameIfNeeded()
    fun generatePassword(): String

    fun pasteToClipboard(text: String)
    fun validationError(
        password: String,
        type: SignerStoreItem.PasswordType
    ): String?

    fun addAccount()
    fun accountName(idx: Int): String
    fun accountDerivationPath(idx: Int): String
    fun accountAddress(idx: Int): String
    fun setAccountName(name: String, idx: Int)
    fun accountsCount(): Int
}

class DefaultMnemonicNewInteractor(
    private val signerStoreService: SignerStoreService,
    private val passwordService: PasswordService,
    private val addressService: AddressService,
): MnemonicNewInteractor {
    private var bip39: Bip39 = Bip39.from(ES128)
    private var bip44: Bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
    private var accountNames: MutableList<String> = mutableListOf("")
    private var accountAddresses: MutableList<String> = mutableListOf(
        addressService.address(bip44.deriveChildKey(defaultDerivationPath()))
    )
    private var accountPaths: MutableList<String> =  mutableListOf(
        defaultDerivationPath()
    )
    
    override var name: String = ""
        set(value) { field = value; setAccountName(value, 0); }

    override var salt: String = ""
        set(value) { field = value; regenerateAccountsAndAddresses(); }

    override var saltMnemonicOn: Boolean = false
        set(value) { field = value; regenerateAccountsAndAddresses(); }

    override var entropySize: Bip39.EntropySize = ES128
        set(value) { field = value; regenerateAccountsAndAddresses(); }

    override var iCloudSecretStorage: Boolean = false
    override var passwordType: SignerStoreItem.PasswordType = BIO
    override var password: String = ""
    override var passUnlockWithBio: Boolean = true

    override fun mnemonic(): String = bip39.mnemonic.joinToString(" ")

    @OptIn(ExperimentalStdlibApi::class)
    override fun createMnemonicSigner(): SignerStoreItem {
        val item = signerStoreService.createMnemonicSigner(
            MnemonicSignerConfig(
                mnemonic = bip39.mnemonic,
                name = name,
                passUnlockWithBio = passUnlockWithBio,
                iCloudSecretStorage = iCloudSecretStorage,
                saltMnemonic = saltMnemonicOn,
                passwordType = passwordType,
            ),
            password,
            salt
        )
        for (i in 1..<accountPaths.count()) {
            val path = accountPaths[i]
            val name = accountNames[i]
            signerStoreService.addAccount(item, password, salt, path, name)
        }
        return item
    }

    override fun regenerateMnemonic() {
        bip39 = Bip39.from(entropySize, salt)
        bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        regenerateAccountsAndAddresses()
    }

    override fun generateDefaultNameIfNeeded() {
        if (name.isEmpty()) {
            name = Localized("mnemonic.defaultWalletName")
            val mnemonicsCnt = signerStoreService.mnemonicSignerItems().count()
            if (mnemonicsCnt > 0)
                name = "$name $mnemonicsCnt"
        }
    }

    override fun generatePassword(): String = secureRand(32).toHexString()

    override fun pasteToClipboard(text: String) = ClipboardService().paste(text)

    override fun validationError(
        password: String,
        type: SignerStoreItem.PasswordType
    ): String? = passwordService.validationError(password, type)

    override fun addAccount() {
        generateDefaultNameIfNeeded()
        accountNames.add("$name, acc: ${accountsCount()}")
        accountPaths.add(incrementedDerivationPath(accountPaths.last()))
        accountAddresses.add(
            addressService.address(bip44.deriveChildKey(accountPaths.last()))
        )
    }

    override fun accountName(idx: Int): String = accountNames[idx]

    override fun accountDerivationPath(idx: Int): String = accountPaths[idx]

    override fun accountAddress(idx: Int): String = accountAddresses[idx]

    override fun setAccountName(name: String, idx: Int) {
        accountNames[idx] = name
    }

    override fun accountsCount(): Int  = accountNames.count()

    private fun regenerateAccountsAndAddresses() {
        bip39 = Bip39(bip39.mnemonic, salt, bip39.worldList)
        bip44 = Bip44(bip39.seed(), ExtKey.Version.MAINNETPRV)
        accountPaths.forEachIndexed { idx, path ->
            accountAddresses[idx] = addressService.address(
                bip44.deriveChildKey(path)
            )
        }
    }
}