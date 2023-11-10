package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3walletcore.services.actions.Action
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord

interface MnemonicConfirmationInteractor {
    fun prefix(mnemonic: String, cursorLocation: Int): String
    fun potentialMnemonicWords(prefix: String?): List<String>
    fun findInvalidWords(mnemonic: String?): List<MnemonicWord>
    fun isValidPrefix(prefix: String): Boolean
    fun isMnemonicValid(mnemonic: String, salt: String?): Boolean
    fun showSalt(): Boolean
    fun markConfirmActionComplete()
    fun mnemonicError(mnemonic: List<String>, salt: String): MnemonicServiceError?
}

class DefaultMnemonicConfirmationInteractor(
    private val signerStoreService: SignerStoreService,
    private val actionsService: ActionsService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationInteractor {

    override fun prefix(mnemonic: String, cursorLocation: Int): String =
        mnemonicService.prefix(mnemonic, cursorLocation)

    override fun potentialMnemonicWords(prefix: String?): List<String> =
        mnemonicService.potentialMnemonicWords(prefix)

    override fun findInvalidWords(mnemonic: String?): List<MnemonicWord> =
        mnemonicService.findInvalidWords(mnemonic)

    override fun isValidPrefix(prefix: String): Boolean =
        mnemonicService.isValidPrefix(prefix)

    override fun isMnemonicValid(mnemonic: String, salt: String?): Boolean =
        mnemonicService.mnemonicError(mnemonic, salt) == null

    override fun showSalt(): Boolean {
        val keyStoreItem = signerStoreService.selected ?: return false
        return keyStoreItem.saltMnemonic
    }

    override fun markConfirmActionComplete() {
        actionsService.markComplete(Action.ConfirmMnemonic)
    }

    override fun mnemonicError(
        mnemonic: List<String>,
        salt: String
    ): MnemonicServiceError? =
        mnemonicService.mnemonicError(mnemonic.joinToString(" "), salt)
}
