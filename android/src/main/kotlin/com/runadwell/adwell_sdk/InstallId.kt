package com.runadwell.adwell_sdk

import java.util.UUID

/**
 * This install's id: read from storage, or generated once and saved
 * (ADR 0002 D10). Lowercase UUID, same shape as on iOS.
 */
internal class InstallId(
    private val read: () -> String?,
    private val write: (String) -> Unit,
    private val generate: () -> String = { UUID.randomUUID().toString() },
) {
    @Volatile private var cached: String? = null

    fun value(): String = cached ?: synchronized(lock) {
        cached ?: (read()?.takeIf { it.isNotEmpty() } ?: generate().lowercase().also(write))
            .also { cached = it }
    }

    private companion object {
        val lock = Any() // one id per process, even with several Flutter engines
    }
}
