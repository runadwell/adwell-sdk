import 'package:adwell_sdk/adwell_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  void answer(Object? Function(MethodCall call)? handler) {
    calls.clear();
    messenger.setMockMethodCallHandler(
      Adwell.channel,
      handler == null
          ? null
          : (call) async {
              calls.add(call);
              return handler(call);
            },
    );
  }

  tearDown(() => answer(null));

  test('channel name matches the native side', () {
    expect(Adwell.channel.name, 'com.runadwell.sdk');
  });

  test('configure forwards key, environment and log level', () async {
    answer((_) => null);
    await Adwell.configure(apiKey: 'pk_test_x');
    await Adwell.configure(
      apiKey: 'pk_test_y',
      environment: AdwellEnvironment.staging,
      logLevel: AdwellLogLevel.debug,
    );
    expect(calls.map((c) => [c.method, c.arguments]), [
      [
        'configure',
        {'apiKey': 'pk_test_x', 'environment': 'production', 'logLevel': 'off'},
      ],
      [
        'configure',
        {'apiKey': 'pk_test_y', 'environment': 'staging', 'logLevel': 'debug'},
      ],
    ]);
  });

  test('installId returns the native id', () async {
    answer((_) => '6f1c0000-0000-4000-8000-000000000001');
    expect(await Adwell.installId, '6f1c0000-0000-4000-8000-000000000001');
    expect(calls.single.method, 'installId');
  });

  test('native errors never reach the app', () async {
    answer((_) => throw PlatformException(code: 'boom'));
    await Adwell.configure(apiKey: 'pk_live_x');
    expect(await Adwell.installId, isNull);
  });

  test('no native side (web, desktop): nothing throws, no id', () async {
    answer(null);
    await Adwell.configure(apiKey: 'pk_live_x');
    expect(await Adwell.installId, isNull);
  });
}
