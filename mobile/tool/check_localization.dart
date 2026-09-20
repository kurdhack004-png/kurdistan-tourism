import 'dart:convert';
import 'dart:io';

void main() {
  final files = ['ckb.json', 'ar.json', 'en.json'];
  final maps = <String, Map<String, dynamic>>{};

  for (final name in files) {
    final file = File('assets/i18n/$name');
    if (!file.existsSync()) {
      stderr.writeln('Missing localization file: $name');
      exitCode = 1;
      return;
    }
    try {
      maps[name] = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('Invalid JSON in $name: $e');
      exitCode = 1;
      return;
    }
  }

  final base = maps['ckb.json']!.keys.toSet();
  var failed = false;
  for (final name in files.skip(1)) {
    final keys = maps[name]!.keys.toSet();
    final missing = base.difference(keys).toList()..sort();
    final extra = keys.difference(base).toList()..sort();
    if (missing.isNotEmpty || extra.isNotEmpty) {
      failed = true;
      stderr.writeln('${name}: missing=${missing.join(',')} extra=${extra.join(',')}');
    }
  }

  if (failed) {
    exitCode = 1;
    return;
  }
  stdout.writeln('Localization key check passed: ${base.length} keys in ckb/ar/en.');
}
