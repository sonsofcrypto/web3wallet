package com.sonsofcrypto.web3wallet.android.common

import android.os.Bundle
import android.view.View
import androidx.activity.addCallback
import androidx.fragment.app.Fragment
import com.sonsofcrypto.web3wallet.android.R
import smartadapter.internal.extension.name

class NavigationFragment(
    private val initialFragment: Fragment?
) : Fragment(R.layout.navigation_fragment) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureOnBackPressedDispatcher()
    }

    private fun configureOnBackPressedDispatcher() {
        requireActivity().onBackPressedDispatcher.addCallback(this) {
            if (childFragmentManager.backStackEntryCount == 0) {
                // If nothing else to pop, we simply close the activity
                requireActivity().finish()
            } else {
                // If anything to pop, we pop it
                childFragmentManager.popBackStack()
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val fragment = initialFragment ?: return
        childFragmentManager
            .beginTransaction()
            .replace(R.id.container, fragment)
            .setReorderingAllowed(true)
            .commit()
    }

    fun present(fragment: Fragment, animated: Boolean = true) {
        childFragmentManager
            .beginTransaction()
            .setCustomAnimations(
                R.anim.slide_up,
                R.anim.slide_down,
                R.anim.slide_up,
                R.anim.slide_down
            )
            .add(R.id.container, fragment)
            .setReorderingAllowed(true)
            .addToBackStack(fragment::class.name)
            .commit()
    }

    fun push(fragment: Fragment, animated: Boolean = true) {
            childFragmentManager
                .beginTransaction()
                .setCustomAnimations(
                    R.anim.slide_in,
                    R.anim.slide_out,
                    R.anim.slide_in,
                    R.anim.slide_out
                )
                .add(R.id.container, fragment)
                .setReorderingAllowed(true)
                .addToBackStack(fragment::class.name)
                .commit()
    }

    fun dismiss(animated: Boolean = true, onCompletion: (() -> Unit)? = null) {
        childFragmentManager.popBackStack()
        onCompletion?.let { it() }
    }

    fun popToRoot() {
        if (childFragmentManager.backStackEntryCount > 1) {
            dismiss(true)
            popToRoot()
        }
    }
}
