package com.sonsofcrypto.web3walletcore.modules.authenticate

import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem.PasswordType.BIO
import com.sonsofcrypto.web3lib.services.keyStore.KeyStoreItem.PasswordType.PIN
import com.sonsofcrypto.web3lib.utils.WeakRef
import com.sonsofcrypto.web3walletcore.extensions.Localized
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticatePresenterEvent.*
import com.sonsofcrypto.web3walletcore.modules.authenticate.AuthenticateWireframeDestination.Dismiss

sealed class AuthenticatePresenterEvent {
    object DidCancel: AuthenticatePresenterEvent()
    object DidConfirm: AuthenticatePresenterEvent()
    data class DidChangePassword(val text: String): AuthenticatePresenterEvent()
    data class DidChangeSalt(val text: String): AuthenticatePresenterEvent()
}

interface AuthenticatePresenter {
    fun present()
    fun handle(event: AuthenticatePresenterEvent)
}

class DefaultAuthenticatePresenter(
    private val view: WeakRef<AuthenticateView>?,
    private val wireframe: AuthenticateWireframe,
    private val interactor: AuthenticateInteractor,
    private val context: AuthenticateWireframeContext,
): AuthenticatePresenter {
    private var password: String = ""
    private var salt: String = ""

    override fun present() {
        updateView()
        if (context.keyStoreItem?.passUnlockWithBio == true) return
        interactor.unlockWithBiometrics(
            context.keyStoreItem!!,
            Localized("authenticate.title.unlock")
        ) { authData, _ ->
            if (authData != null) { password = authData.password; updateView() }
            else { handle(DidCancel) }
        }
    }

    override fun handle(event: AuthenticatePresenterEvent) {
        when (event) {
            is DidCancel -> {
                wireframe.navigate(Dismiss)
                context.handler(null, null)
            }
            is DidConfirm -> {
                if (interactor.isValid(context.keyStoreItem!!, password, salt)) {
                    wireframe.navigate(Dismiss)
                    context.handler(AuthenticateData(password, salt), null)
                } else {
                    view?.get()?.animateError()
                }
            }
            is DidChangePassword -> { password = event.text }
            is DidChangeSalt -> { salt = event.text }
        }
    }

    private fun updateView() = view?.get()?.update(viewModel())

    private fun viewModel(): AuthenticateViewModel =
        AuthenticateViewModel(
            Localized("authenticate.title.unlock"),
            password,
            makePassType(),
            Localized("authenticate.placeholder.password"),
            salt,
            Localized("authenticate.placeholder.salt"),
            context.keyStoreItem?.passwordType != BIO,
            context.keyStoreItem?.saltMnemonic ?: false
        )

    private fun makePassType(): AuthenticateViewModel.PassType =
        when (context.keyStoreItem!!.passwordType) {
            PIN -> AuthenticateViewModel.PassType.PIN
            else -> AuthenticateViewModel.PassType.PASS
        }
}
