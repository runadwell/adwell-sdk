import Flutter
// SwiftPM builds AdwellSDK as its own module. CocoaPods compiles the vendored
// copy into this module, so there is nothing to import.
#if canImport(AdwellSDK)
@_spi(Bridge) import AdwellSDK
#endif

/// Forwards `com.runadwell.sdk` calls to AdwellSDK. No logic of its own
/// (ADR 0002 D1).
public final class AdwellSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.runadwell.sdk", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(AdwellSdkPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            let args = call.arguments as? [String: Any] ?? [:]
            var options = AdwellOptions(
                environment: args["environment"] as? String == "staging" ? .staging : .production,
                logLevel: args["logLevel"] as? String == "debug" ? .debug : .off
            )
            options.bridge = "flutter"
            Adwell.configure(apiKey: args["apiKey"] as? String ?? "", options: options)
            result(nil)
        case "installId":
            // The first read touches the Keychain: keep it off the main thread.
            DispatchQueue.global(qos: .utility).async {
                let id = Adwell.installID
                DispatchQueue.main.async { result(id) }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
