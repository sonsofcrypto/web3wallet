package com.sonsofcrypto.web3lib.formatters

import com.sonsofcrypto.web3lib.utils.BigDec
import kotlin.test.Test
import kotlin.test.assertEquals

class BigDecFormatterTests {

    private fun output(a: String?, s: Formatters.Style): List<Formatters.Output> {
        return if (a == null) {
            Formatters.bigDec.format(null, s)
        } else {
            Formatters.bigDec.format(BigDec.from(a), s)
        }
    }

    @Test
    fun testFiatMaxUSD1() {
        val output = output("2100.0000000000000043", Formatters.Style.Max)
        assertEquals(listOf(Formatters.Output.Normal("2100.0000000000000043")), output)
    }
    @Test
    fun testFiatMaxUSD2() {
        val output = output("0.00003200000000043", Formatters.Style.Max)
        assertEquals(listOf(Formatters.Output.Normal("0.00003200000000043")), output)
    }
    @Test
    fun testFiatMaxUSD3() {
        val output = output("0.93", Formatters.Style.Max)
        assertEquals(listOf(Formatters.Output.Normal("0.93")), output)
    }
    @Test
    fun testFiatMaxUSD4() {
        val output = output("1213.93", Formatters.Style.Max)
        assertEquals(listOf(Formatters.Output.Normal("1213.93")), output)
    }

    @Test
    fun testFiatCustomUSD1() {
        val actual = output("2100.0000000000000043", Formatters.Style.Custom(20u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("2.10"),
            Formatters.Output.Down("16"),
            Formatters.Output.Normal("43K")
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD2() {
        val actual = output("0.00000608", Formatters.Style.Custom(9u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("0.0"),
            Formatters.Output.Down("5"),
            Formatters.Output.Normal("608")
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD31() {
        val output = output("1013.33", Formatters.Style.Custom(4u))
        assertEquals(listOf(Formatters.Output.Normal("1K")), output)
    }
    @Test
    fun testFiatCustomUSD32() {
        val output = output("1013.33", Formatters.Style.Custom(5u))
        assertEquals(listOf(Formatters.Output.Normal("1.01K")), output)
    }
    @Test
    fun testFiatCustomUSD33() {
        val output = output("1213.33", Formatters.Style.Custom(4u))
        assertEquals(listOf(Formatters.Output.Normal("1.2K")), output)
    }
    @Test
    fun testFiatCustomUSD4() {
        val output = output("1213.33", Formatters.Style.Custom(5u))
        assertEquals(listOf(Formatters.Output.Normal("1.21K")), output)
    }
    @Test
    fun testFiatCustomUSD5() {
        val output = output("1213.33", Formatters.Style.Custom(6u))
        assertEquals(listOf(Formatters.Output.Normal("1.213K")), output)
    }
    @Test
    fun testFiatCustomUSD6() {
        val output = output("1213.33", Formatters.Style.Custom(8u))
        assertEquals(listOf(Formatters.Output.Normal("1213.33")), output)
    }
    @Test
    fun testFiatCustomUSD7() {
        val actual = output("2100000323.0000000000000043", Formatters.Style.Custom(20u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("2.10"),
            Formatters.Output.Down("5"),
            Formatters.Output.Normal("3230"),
            Formatters.Output.Down("14"),
            Formatters.Output.Normal("43B")
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD8() {
        val actual = output("160806397316", Formatters.Style.Custom(11u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("160.806397B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD9() {
        val actual = output("16949329792", Formatters.Style.Custom(12u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16949329792"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD10() {
        val actual = output("1234.56", Formatters.Style.Custom(5u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1.23K"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD11() {
        val actual = output("1234.56", Formatters.Style.Custom(6u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1.234K"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD12() {
        val actual = output("1234.56", Formatters.Style.Custom(8u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1234.56"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD13() {
        val actual = output("1234.56", Formatters.Style.Custom(9u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1234.56"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD14() {
        val actual = output("1234.56", Formatters.Style.Custom(12u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1234.56"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD15() {
        val actual = output("16949329792", Formatters.Style.Custom(10u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16.949329B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD16() {
        val actual = output("16949329792", Formatters.Style.Custom(4u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD17() {
        val actual = output("16949329792", Formatters.Style.Custom(4u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD18() {
        val actual = output("16949329792", Formatters.Style.Custom(3u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD19() {
        val actual = output("16949329792", Formatters.Style.Custom(2u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD20() {
        val actual = output("16949329792", Formatters.Style.Custom(1u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD21() {
        val actual = output("16949329792", Formatters.Style.Custom(0u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("16B"),
        )
        assertEquals(expected, actual)
    }
    @Test
    fun testFiatCustomUSD22() {
        val actual = output("1303.60", Formatters.Style.Custom(10u))
        val expected: List<Formatters.Output> = listOf(
            Formatters.Output.Normal("1303.60"),
        )
        assertEquals(expected, actual)
    }
}