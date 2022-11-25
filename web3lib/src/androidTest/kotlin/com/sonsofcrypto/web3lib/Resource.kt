package com.sonsofcrypto.web3lib

import java.io.File

const val RESOURCE_PATH = "./src/res"


actual class Resource {
    actual val name: String
    private val file: File

    actual constructor(name: String) {
        this.name = name
        this.file = File("$RESOURCE_PATH/$name")
        println("===== LOG ======")
        println(file.path)
        println(file.absolutePath)
    }


    actual fun exists(): Boolean = file.exists()

    actual fun readText(): String = file.readText()
}