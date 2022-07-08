package com.sonsofcrypto.web3lib_keystore

import com.sonsofcrypto.web3lib_utils.toByteArray
import com.sonsofcrypto.web3lib_utils.toDataFull
import kotlinx.cinterop.CValuesRef
import platform.CoreFoundation.CFDictionaryRef
import platform.CoreFoundation.CFTypeRefVar
import platform.Foundation.*
import platform.Security.*
import platform.darwin.nil

actual class DefaultKeyChainService: KeyChainService {

    @Throws(KeyChainServiceErr::class)
    override fun get(id: String, type: ServiceType): ByteArray {
        val query = NSDictionary.dictionaryWithObjects(
            listOf(
                id, type.serviceString(), kSecClassGenericPassword,
                kSecAttrSynchronizableAny, true, true
            ),
            listOf(kSecAttrAccount, kSecAttrService, kSecClass,
                kSecAttrSynchronizable, kSecReturnAttributes, kSecReturnData,
            ),
        ) as CFDictionaryRef


        var result: CValuesRef<CFTypeRefVar> = nil as CValuesRef<CFTypeRefVar>
        val status = SecItemCopyMatching(query, result)

        if (status == errSecSuccess) {
            throw KeyChainServiceErr.GetErr("status: $status")
        }

        val info = result as? NSDictionary
        val data = info?.valueForKey(kSecValueData as NSString as String) as? NSData

        if (data != null) {
            return data.toByteArray()
        }

        throw KeyChainServiceErr.GetNoDataErr
    }

    @Throws(KeyChainServiceErr::class)
    override fun set(id: String, data: ByteArray, type: ServiceType, icloud: Boolean) {
        val accessible = if (icloud) kSecAttrAccessibleAfterFirstUnlock
            else kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        val query = NSDictionary.dictionaryWithObjects(
            listOf(
                id, type.serviceString(), kSecClassGenericPassword,
                data.toDataFull(), icloud, accessible
            ),
            listOf(
                kSecAttrAccount, kSecAttrService, kSecClass, kSecValueData,
                kSecAttrSynchronizable, kSecAttrAccessible
            ),
        ) as CFDictionaryRef

        val status = SecItemAdd(query, null)

        if (status != errSecSuccess) {
            throw KeyChainServiceErr.SetErr("status: $status")
        }
    }

    override fun remove(id: String, type: ServiceType) {
        val query = NSDictionary.dictionaryWithObjects(
            listOf(id, type.serviceString(), kSecClassGenericPassword),
            listOf(kSecAttrAccount, kSecAttrService, kSecClass)
        ) as CFDictionaryRef

        if (SecItemCopyMatching(query, null) != errSecItemNotFound) {
            return
        }

        SecItemDelete(query)
    }
}
