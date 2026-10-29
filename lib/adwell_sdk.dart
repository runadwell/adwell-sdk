/// Adwell for Flutter: a thin bridge over the native `AdwellSDK`.
///
/// Call [Adwell.configure] once at launch, then give [Adwell.installId] to
/// your billing SDK as the `adwell_install_id` attribute on every launch.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Which Adwell API receives installs. `pk_live_` keys belong to
/// [production], `pk_test_` keys to [staging].
enum AdwellEnvironment { production, staging }

/// [debug] prints what the SDK does in release builds too. Setup errors
/// (a wrong key, a key for another app) are printed in debug builds either way.
enum AdwellLogLevel { off, debug }

/// Nothing here throws or blocks the UI. On platforms without a native side
/// (web, desktop) [configure] does nothing and [installId] is null.
abstract final class Adwell {
  @visibleForTesting
  static const channel = MethodChannel('com.runadwell.sdk');

  /// Starts sending this install to Adwell in the background. Calling it
  /// again is a no-op.
  static Future<void> configure({
    required String apiKey,
    AdwellEnvironment environment = AdwellEnvironment.production,
    AdwellLogLevel logLevel = AdwellLogLevel.off,
  }) async {
    try {
      await channel.invokeMethod<void>('configure', {
        'apiKey': apiKey,
        'environment': environment.name,
        'logLevel': logLevel.name,
      });
    } catch (e) {
      _report(e);
    }
  }

  /// This install's id: a lowercase UUID, stable across launches and, on
  /// iOS, across reinstalls on the same device.
  static Future<String?> get installId async {
    try {
      return await channel.invokeMethod<String>('installId');
    } catch (e) {
      _report(e);
      return null;
    }
  }

  static void _report(Object e) {
    if (kDebugMode) debugPrint('[Adwell] Error: $e');
  }
}
