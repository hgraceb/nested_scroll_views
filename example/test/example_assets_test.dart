import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('example bundles the icon fonts used by its navigation bar', () {
    final assets = Directory(Platform.environment['EXAMPLE_ASSET_DIR'] ?? 'build/flutter_assets');
    final manifestFile = File('${assets.path}/FontManifest.json');
    expect(manifestFile.existsSync(), isTrue, reason: 'Build the example assets before running this test.');
    final manifest = jsonDecode(manifestFile.readAsStringSync()) as List<dynamic>;
    final icons = [Icons.mode_night, Icons.cloud, Icons.light_mode];
    final families = icons.map((icon) {
      return icon.fontPackage == null ? icon.fontFamily! : 'packages/${icon.fontPackage}/${icon.fontFamily}';
    }).toSet();
    for (final family in families) {
      final entry = manifest.singleWhere((entry) => entry['family'] == family) as Map<String, dynamic>;
      for (final font in entry['fonts'] as List<dynamic>) {
        final asset = File('${assets.path}/${font['asset']}');
        expect(asset.existsSync(), isTrue, reason: '$family is declared but ${asset.path} is missing');
        expect(asset.lengthSync(), greaterThan(1000), reason: '$family font asset is empty or truncated');
      }
    }
  });
}
