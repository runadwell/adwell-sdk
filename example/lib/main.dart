import 'package:adwell_sdk/adwell_sdk.dart';
import 'package:flutter/material.dart';

// flutter run --dart-define=ADWELL_KEY=pk_test_... --dart-define=ADWELL_ENV=staging
const _key = String.fromEnvironment('ADWELL_KEY');
const _env = String.fromEnvironment('ADWELL_ENV', defaultValue: 'production');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Adwell.configure(
    apiKey: _key,
    environment: _env == 'staging'
        ? AdwellEnvironment.staging
        : AdwellEnvironment.production,
    logLevel: AdwellLogLevel.debug,
  );
  // In your app: Purchases.setAttributes({'adwell_install_id': id}) on every launch.
  final id = await Adwell.installId;
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Adwell example')),
      body: Center(child: SelectableText('install id\n${id ?? 'none'}')),
    ),
  ));
}
