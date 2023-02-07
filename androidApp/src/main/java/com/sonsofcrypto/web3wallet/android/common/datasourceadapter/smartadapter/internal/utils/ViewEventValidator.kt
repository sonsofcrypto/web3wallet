package smartadapter.internal.utils

import com.sonsofcrypto.web3wallet.android.R

/*
 * Created by Manne Öhlund on 2019-06-11.
 * Copyright (c) All rights reserved.
 */

/**
 * Checks if auto view events are of the predefined types provided by the SmartRecyclerAdapter library.
 */
object ViewEventValidator {

    private val autoViewEvents = listOf(
        R.id.undefined,
        R.id.event_on_click,
        R.id.event_on_long_click,
        R.id.event_on_item_selected
    )

    fun isViewEventIdValid(viewEventId: Int): Boolean {
        return autoViewEvents.contains(viewEventId)
    }
}
