package com.sonsofcrypto.web3wallet.android.common.extenstion

import android.view.View

fun <T> View.byId(id: Int): T = findViewById(id) as T
