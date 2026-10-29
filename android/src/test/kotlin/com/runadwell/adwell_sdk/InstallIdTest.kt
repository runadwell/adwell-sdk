package com.runadwell.adwell_sdk

import kotlin.test.Test
import kotlin.test.assertEquals

internal class InstallIdTest {
    @Test
    fun generatesOnceAndSaves() {
        var stored: String? = null
        var generated = 0
        val id = InstallId({ stored }, { stored = it }, { generated++; "6F1C0000-0000-4000-8000-000000000001" })
        assertEquals("6f1c0000-0000-4000-8000-000000000001", id.value())
        assertEquals("6f1c0000-0000-4000-8000-000000000001", stored)
        assertEquals(id.value(), InstallId({ stored }, { stored = it }, { "other" }).value())
        assertEquals(1, generated)
    }

    @Test
    fun keepsAStoredId() {
        var writes = 0
        val id = InstallId({ "6f1c0000-0000-4000-8000-000000000002" }, { writes++ }, { error("never generated") })
        assertEquals("6f1c0000-0000-4000-8000-000000000002", id.value())
        assertEquals(0, writes)
    }

    @Test
    fun replacesAnEmptyValue() {
        var stored: String? = ""
        val id = InstallId({ stored }, { stored = it }, { "6f1c0000-0000-4000-8000-000000000003" })
        assertEquals("6f1c0000-0000-4000-8000-000000000003", id.value())
    }
}
