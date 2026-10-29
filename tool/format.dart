import 'dart:io';

/// 格式化自有代码，跳过必须保留上游原文的 Flutter 副本
Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty && (arguments.length != 1 || arguments.single != '--check')) {
    stderr.writeln('Usage: dart tool/format.dart [--check]');
    exitCode = 64;
    return;
  }

  final root = Platform.script.resolve('../');
  final excluded = root.resolve('lib/src/flutter/');
  final options = File.fromUri(root.resolve('analysis_options.yaml')).readAsStringSync();
  final pageWidth = RegExp(r'^\s*page_width:\s*(\d+)\s*$', multiLine: true).firstMatch(options)?.group(1);
  if (pageWidth == null) {
    throw StateError('Missing formatter.page_width in analysis_options.yaml.');
  }
  // 兼容 Dart 3.5 的格式化参数
  final version = Platform.version.split('.').take(2).map(int.parse).toList();
  final widthFlag = version[0] == 3 && version[1] < 7 ? '--line-length' : '--page-width';
  final files = <String>[
    for (final path in ['lib', 'test', 'tool', 'example/lib', 'example/test'])
      ..._sourceFiles(Directory.fromUri(root.resolve('$path/')), excluded),
  ]..sort();

  final process = await Process.start(
    Platform.resolvedExecutable,
    [
      'format',
      '$widthFlag=$pageWidth',
      if (arguments.contains('--check')) ...['--output=none', '--set-exit-if-changed'],
      ...files,
    ],
    workingDirectory: Directory.fromUri(root).path,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}

Iterable<String> _sourceFiles(Directory directory, Uri excluded) sync* {
  if (!directory.existsSync() || directory.uri == excluded) {
    return;
  }
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is Directory) {
      yield* _sourceFiles(entity, excluded);
    } else if (entity is File && entity.path.endsWith('.dart')) {
      yield entity.path;
    }
  }
}
