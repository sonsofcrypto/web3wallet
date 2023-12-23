package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.services.keyStore.SignerStoreService
import com.sonsofcrypto.web3walletcore.common.helpers.MnemonicPresenterHelper
import com.sonsofcrypto.web3walletcore.services.actions.Action
import com.sonsofcrypto.web3walletcore.services.actions.ActionsService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicService
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicServiceError
import com.sonsofcrypto.web3walletcore.services.mnemonic.MnemonicWord

interface MnemonicConfirmationInteractor {
    var mnemonicStr: String
    var cursorLoc: Int
    var salt: String

    fun mnemonic(): String
    fun potentialMnemonicWords(): List<String>
    fun mnemonicWordsInfo(): List<MnemonicWord>
    fun isMnemonicValid(): Boolean
    fun mnemonicError(): MnemonicServiceError?

    fun showSalt(): Boolean
    fun markConfirmActionComplete()
}

class DefaultMnemonicConfirmationInteractor(
    private val signerStoreService: SignerStoreService,
    private val actionsService: ActionsService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationInteractor {
    private val helper = MnemonicPresenterHelper()

    override var mnemonicStr: String = ""
    override var cursorLoc: Int = 0
    override var salt: String = ""

    override fun mnemonic(): String =
        mnemonicStr.trim()

    override fun potentialMnemonicWords(): List<String> = mnemonicService
        .potentialMnemonicWords(mnemonicService.prefix(mnemonicStr, cursorLoc))

    override fun mnemonicWordsInfo(): List<MnemonicWord> {
        val prefix = mnemonicService.prefix(mnemonicStr, cursorLoc)
        val words = mnemonicService.findInvalidWords(mnemonicStr)
        return helper.updateWordsInfo(words, prefix, cursorLoc) {
            mnemonicService.isValidPrefix(it)
        }
    }

    override fun isMnemonicValid(): Boolean =
        mnemonicError() == null

    override fun mnemonicError(): MnemonicServiceError? =
        mnemonicService.mnemonicError(mnemonicStr, salt)

    override fun showSalt(): Boolean {
        val keyStoreItem = signerStoreService.selected ?: return false
        return keyStoreItem.saltMnemonic
    }

    override fun markConfirmActionComplete() {
        actionsService.markComplete(Action.ConfirmMnemonic)
    }
}
