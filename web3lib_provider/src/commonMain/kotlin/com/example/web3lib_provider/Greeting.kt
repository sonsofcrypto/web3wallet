package com.example.web3lib_provider

class Greeting {
    fun greeting(): String {
        return "Hello, ${Platform().platform}!"
    }
}