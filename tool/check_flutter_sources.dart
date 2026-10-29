import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

const _revision = '737ba8f885dc774b53b442759999a312c9461e4e';
const _materialVersion = '1.8.0';

// Boundaries include the upstream comments and whitespace of each whole block.
const _blocks = <String, List<(String, String?)>>{
  'widgets/page_view.dart': [
    ('class _ForceImplicitScrollPhysics', '/// Scroll physics used by a [PageView].'),
    ('const PageScrollPhysics _kPagePhysics', null),
  ],
  'widgets/scroll_view.dart': [
    ('/// A widget that combines a [Scrollable]', null),
  ],
  'widgets/scrollable.dart': [
    ('// The return type of _performEnsureVisible.', '// 2D SCROLLING'),
  ],
  'widgets/scrollable_helpers.dart': [
    ('/// An auto scroller that scrolls', '/// A typedef for a function that can calculate'),
  ],
  'widgets/single_child_scroll_view.dart': [
    ('/// A box in which a single widget can be scrolled.', null),
  ],
  'material/tabs.dart': [
    ('/// A page view that displays the widget', '/// Displays a single circle with the specified size'),
  ],
};

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart tool/check_flutter_sources.dart <flutter-git-checkout>');
    exitCode = 64;
    return;
  }

  final root = Platform.script.resolve('../');
  for (final entry in _blocks.entries) {
    final String source;
    if (entry.key == 'material/tabs.dart') {
      final uri = await Isolate.resolvePackageUri(Uri.parse('package:material_ui/src/tabs.dart'));
      if (uri == null) {
        throw StateError('Run flutter pub get to install material_ui.');
      }
      final pubspec = File.fromUri(uri.resolve('../../pubspec.yaml')).readAsStringSync();
      if (!RegExp('^version: ${RegExp.escape(_materialVersion)}\$', multiLine: true).hasMatch(pubspec)) {
        throw StateError('Source verification requires material_ui $_materialVersion.');
      }
      source = File.fromUri(uri).readAsStringSync();
    } else {
      // Read Git blobs so Windows checkout settings cannot change line endings.
      final result = Process.runSync(
        'git',
        ['-C', arguments.single, 'show', '$_revision:packages/flutter/lib/src/${entry.key}'],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      if (result.exitCode != 0) {
        stderr.write(result.stderr);
        exitCode = 1;
        return;
      }
      source = result.stdout as String;
    }
    final headerEnd = source.indexOf('/// @docImport');
    if (headerEnd < 0) {
      throw StateError('Missing copyright boundary: ${entry.key}');
    }
    final assembly = entry.key == 'widgets/scrollable_helpers.dart' ? 'widgets/scrollable.dart' : entry.key;
    final expected = StringBuffer(source.substring(0, headerEnd))
      ..write("part of 'package:nested_scroll_views/src/assembly/$assembly';\n\n");
    var previousEnd = headerEnd;
    for (final (start, end) in entry.value) {
      final from = source.indexOf(start, previousEnd);
      final to = end == null ? source.length : source.indexOf(end, from);
      if (from < previousEnd || to <= from) {
        throw StateError('Missing or unordered source block: ${entry.key}');
      }
      expected.write(source.substring(from, to));
      previousEnd = to;
    }

    final bytes = utf8.encode(expected.toString());
    final actual = File.fromUri(root.resolve('lib/src/flutter/${entry.key}')).readAsBytesSync();
    var index = 0;
    while (index < bytes.length && index < actual.length && bytes[index] == actual[index]) {
      index++;
    }
    if (index != bytes.length || index != actual.length) {
      stderr.writeln('${entry.key}: differs at byte $index');
      exitCode = 1;
    } else {
      stdout.writeln('${entry.key}: identical');
    }
  }
}
