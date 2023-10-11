package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3walletcore.services.actions.Action
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord

interface MnemonicConfirmationInteractor {
    fun potentialMnemonicWords(prefix: String?): List<String>
    fun findInvalidWords(mnemonic: String?): List<MnemonicWord>
    fun isValidPrefix(prefix: String): Boolean
    fun isMnemonicValid(mnemonic: String, salt: String?): Boolean
    fun showSalt(): Boolean
    fun markConfirmActionComplete()
}

class DefaultMnemonicConfirmationInteractor(
    private val signerStoreService: SignerStoreService,
    private val actionsService: ActionsService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationInteractor {

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
}
