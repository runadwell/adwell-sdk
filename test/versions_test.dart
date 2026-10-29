import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ADR 0002 D9 and D11: the plugin, its SwiftPM dependency, its podspec and the
// vendored AdwellSDK copy all carry the same version.
void main() {
  String read(String path) => File(path).readAsStringSync();
  String match(String path, String pattern) =>
      RegExp(pattern, multiLine: true).firstMatch(read(path))!.group(1)!;

  test('one version everywhere', () {
    final version = match('pubspec.yaml', r'^version: (\S+)$');
    expect(match('ios/adwell_sdk.podspec', r"s\.version\s*=\s*'([^']+)'"),
        version);
    expect(
        match('ios/adwell_sdk/Package.swift', r'adwell-ios", exact: "([^"]+)"'),
        version);
    expect(match('ios/vendor/AdwellSDK/VERSION', r'^(\S+) '), version);
    expect(match('ios/vendor/AdwellSDK/Adwell.swift', r'version = "([^"]+)"'),
        version);
    expect(
        match('android/build.gradle.kts', r'^version = "([^"]+)"$'), version);
    expect(match('CHANGELOG.md', r'^## (\S+)$'), version);
  });
}
