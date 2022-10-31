package com.sonsofcrypto.web3walletcore.modules.authenticate

interface AuthenticateView  {
    fun update(viewModel: AuthenticateViewModel)
    fun animateError()
}
