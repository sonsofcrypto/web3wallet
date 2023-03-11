package com.sonsofcrypto.web3wallet.android.common.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.VisualTransformation
import com.sonsofcrypto.web3wallet.android.common.extensions.half
import com.sonsofcrypto.web3wallet.android.common.theme

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun W3WSearchBox(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier,
    placeholder: @Composable (() -> Unit)? = null,
    leadingIcon: @Composable (() -> Unit)? = null,
    trailingIcon: @Composable (() -> Unit)? = null,
) {
    BasicTextField(
        value = value,
        onValueChange = onValueChange,
        textStyle = TextStyle(
            color = theme().colors.textPrimary,
            fontSize = theme().fonts.body.fontSize,
            fontWeight = theme().fonts.body.fontWeight,
        ),
        singleLine = true,
        modifier = modifier
            .clip(RoundedCornerShape(theme().shapes.cornerRadiusSmall))
            .background(theme().colors.bgPrimary),
        cursorBrush = SolidColor(theme().colors.textPrimary),
        decorationBox = @Composable { innerTextField ->
            // places leading icon, text field with label and placeholder, trailing icon
            TextFieldDefaults.TextFieldDecorationBox(
                value = value,
                visualTransformation = VisualTransformation.None,
                innerTextField = innerTextField,
                placeholder = placeholder,
                leadingIcon = leadingIcon,
                trailingIcon = trailingIcon,
                singleLine = true,
                enabled = true,
                isError = false,
                interactionSource = remember { MutableInteractionSource() },
                colors = W3WTextFieldColors(),
                contentPadding = PaddingValues(theme().shapes.padding.half)
            )
        }
    )
}