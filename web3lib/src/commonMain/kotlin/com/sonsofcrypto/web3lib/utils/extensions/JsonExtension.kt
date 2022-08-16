package com.sonsofcrypto.web3lib.utils.extensions

import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

inline fun <reified T> jsonDecode(string: String): T? {
    return Json.decodeFromString<T>(string)
}
