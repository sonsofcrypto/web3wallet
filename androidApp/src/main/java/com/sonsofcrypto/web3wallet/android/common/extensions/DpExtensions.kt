package com.sonsofcrypto.web3wallet.android.common.extensions

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

val Dp.quarter: Dp get() = (this.value * 0.25).dp
val Dp.half: Dp get() = (this.value * 0.5).dp
val Dp.threeQuarter: Dp get() = (this.value * 0.75).dp
val Dp.oneAndHalf: Dp get() = (this.value * 1.5).dp
val Dp.double: Dp get() = (this.value * 2).dp
