package com.ejlocop.driverge.commons.base

import androidx.appcompat.app.AppCompatActivity
import com.ejlocop.driverge.commons.events.SingleLiveEvent
import com.ejlocop.driverge.commons.events.UiEvent

abstract class BaseActivity : AppCompatActivity() {

    /**
     * Event that can be received in every activity that extends [BaseActivity]
     */
    val uiEvent = SingleLiveEvent<UiEvent>()

}