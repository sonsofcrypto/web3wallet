package com.sonsofcrypto.web3wallet.android.common

import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.activity.addCallback
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentManager.POP_BACK_STACK_INCLUSIVE
import com.sonsofcrypto.web3wallet.android.R
import com.sonsofcrypto.web3wallet.android.modules.compose.dashboard.DashboardFragment
import smartadapter.internal.extension.name

class NavigationFragment(
    private val initialFragment: Fragment?
) : Fragment(R.layout.navigation_fragment) {

    private val navigationStacks = NavigationStacks()

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
                // Pop or dismiss
                popOrDismiss()
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val fragment = initialFragment ?: return
        navigationStacks.present(fragment)
        childFragmentManager
            .beginTransaction()
            .replace(R.id.container, fragment)
            .setReorderingAllowed(true)
            .commit()
    }

    fun present(fragment: Fragment, animated: Boolean = true) {
        navigationStacks.present(fragment)
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
        navigationStacks.push(fragment)
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

    fun popOrDismiss(animated: Boolean = true) {
        if (navigationStacks.canPop) { pop() }
        else { dismiss() }
    }

    fun pop(animated: Boolean = true) {
        navigationStacks.pop()
        childFragmentManager.popBackStack()
    }

    fun dismiss(animated: Boolean = true, onCompletion: (() -> Unit)? = null) {
        navigationStacks.dismiss()
        if (navigationStacks.singleItem) {
            // NOTE: For some reason if there is only a single item in the stack, the method
            // below `popBackStack(navigationStacks.topFragment::class.name, 0)` is not working.
            childFragmentManager.popBackStack()
        } else {
            childFragmentManager.popBackStack(navigationStacks.topFragment::class.name, 0)
        }
        onCompletion?.let { it() }
    }

    fun popToRoot() {
        navigationStacks.popToRoot()
        childFragmentManager.popBackStack(navigationStacks.topFragment::class.name, 0)
    }
}

private class NavigationStacks {

    private var stacks: MutableList<NavigationStack> = mutableListOf()

    fun present(fragment: Fragment) {
        val newStack = NavigationStack()
        newStack.add(fragment)
        stacks.add(newStack)
        print("present()")
    }

    val topFragment: Fragment get() = stacks.last().top
    val canPop: Boolean get() = stacks.last().canPop

    val singleItem: Boolean get() = stacks.count() == 1 && stacks.last().singleItem

    fun push(fragment: Fragment) {
        stacks.last().add(fragment)
        print("push()")
    }

    fun pop() {
        stacks.last().pop()
        print("pop()")
    }

    fun popToRoot() {
        stacks.last().popToRoot()
        print("popToRoot()")
    }

    fun dismiss() {
        stacks.removeLast()
        print("dismiss()")
    }

    private fun print(tag: String) {
        println("[AA] Action = $tag")
        stacks.forEach {
            println("[AA]     Stack(${stacks.indexOf(it)}):")
            it.print()
        }
    }
}

private class NavigationStack {

    private val stack = mutableListOf<Fragment>()

    val top: Fragment get() = stack.last()
    val canPop: Boolean get() = stack.count() > 1
    val singleItem: Boolean get() = stack.count() == 1

    fun add(fragment: Fragment) {
        stack.add(fragment)
    }

    fun pop() {
        stack.removeLast()
    }

    fun popToRoot() {
        val first = stack.first()
        stack.removeAll { it != first }
    }

    fun print() {
        stack.forEach {
            println("[AA]         ${it::class.name}")
        }
    }
}