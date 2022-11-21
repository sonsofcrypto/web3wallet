package com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreService
import com.sonsofcrypto.web3lib.services.networks.NetworksService
import com.sonsofcrypto.web3lib.types.Bip44
import com.sonsofcrypto.web3lib.types.ExtKey
import com.sonsofcrypto.web3lib.utils.Trie
import com.sonsofcrypto.web3lib.utils.bip39.Bip39
import com.sonsofcrypto.web3lib.utils.bip39.WORDLIST_ENGLISH
import com.sonsofcrypto.web3lib.utils.bip39.WordList
import com.sonsofcrypto.web3walletcore.modules.mnemonicConfirmation.MnemonicConfirmationViewModel.WordInfo
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
    fun markDashboardNotificationAsComplete()
}

class DefaultMnemonicConfirmationInteractor(
    private val keyStoreService: KeyStoreService,
    private val actionsService: ActionsService,
    private val networksService: NetworksService,
    private val mnemonicService: MnemonicService,
): MnemonicConfirmationInteractor {

    override fun potentialMnemonicWords(prefix: String?): List<String> =
        mnemonicService.potentialMnemonicWords(prefix)

    override fun findInvalidWords(mnemonic: String?): List<MnemonicWord> =
        mnemonicService.findInvalidWords(mnemonic)

    override fun isValidPrefix(prefix: String): Boolean =
        mnemonicService.isValidPrefix(prefix)

    override fun isMnemonicValid(mnemonic: String, salt: String?): Boolean =
        mnemonicService.isMnemonicValid(mnemonic, salt)

    override fun showSalt(): Boolean {
        val keyStoreItem = keyStoreService.selected ?: return false
        return keyStoreItem.saltMnemonic
    }

    override fun markDashboardNotificationAsComplete() {
        val address = networksService.wallet()?.id() ?: return
        actionsService.completeActionType(Action.Type.ConfirmMnemonic(address))
    }
}
