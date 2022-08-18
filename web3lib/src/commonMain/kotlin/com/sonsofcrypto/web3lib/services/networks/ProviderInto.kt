package com.sonsofcrypto.web3lib.services.networks

import com.sonsofcrypto.web3lib.provider.Provider
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.types.Network
import kotlinx.serialization.Serializable

/** Encapsulates data needed to create web3 `Provider' instance */
@Serializable
data class ProviderInfo(
    val type: Type,
    val name: String? = null,
    val url: String? = null,
    val chainId: Int? = null,
    val currencySymbol: String? = null,
) {
    @Serializable
    enum class Type() { POCKET, CUSTOM }

    /** Create `Provider` instance from description */
    fun toProvider(network: Network): Provider = when (this.type) {
        Type.POCKET -> ProviderPocket(network)
        else -> TODO("Implement custom provider")
    }

    companion object {}
}

/** `ProviderInfo` from provider instance */
fun ProviderInfo.Companion.from(provider: Provider): ProviderInfo = when (provider) {
    is ProviderPocket -> ProviderInfo(ProviderInfo.Type.POCKET)
    else -> ProviderInfo(ProviderInfo.Type.CUSTOM)
}
