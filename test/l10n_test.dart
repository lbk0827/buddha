import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 화면 문자열은 lib/l10n/app_ko.arb 에만 둔다. 코드에 한글 문자열이 새로 들어오면
/// 여기서 걸린다 — 테이블에 키를 더하고 `context.l10n` / `L.current` 로 바꾼다.
void main() {
  final hangul = RegExp(r'[가-힣]');
  final literal = RegExp(r'''(['"])(?:(?!\1).)*[가-힣]''');

  // 저장값 · 조회 키라 한국어 그대로 두는 파일. 화면 표기는 테이블을 거친다.
  const storedValueFiles = {
    'lib/core/time_utils.dart', // 한국어 조사 계산
    'lib/features/ordination/dharma_rank.dart', // 저장되는 법명
    'lib/features/temple/temple_stage.dart', // 저장되는 법명 글자
  };
  // 화면에 나오지 않는 개발자용 문자열.
  const devOnly = [
    'debugPrint',
    'errors.add(',
    'toString()',
    '_VariantBank(',
    'ArgumentError(',
    'StateError(',
  ];

  test('lib/ 코드에 화면용 한글 문자열이 없다', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll('\\', '/');
      if (path.startsWith('lib/l10n/') ||
          path.endsWith('.g.dart') ||
          storedValueFiles.contains(path)) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//') || !hangul.hasMatch(line)) continue;
        // 줄 끝 주석은 떼고 본다.
        final code = line.split(' // ').first;
        if (!literal.hasMatch(code)) continue;
        if (devOnly.any(code.contains)) continue;
        offenders.add('$path:${i + 1}: ${trimmed.trim()}');
      }
    }
    expect(offenders, isEmpty,
        reason: '문자열 테이블(lib/l10n/app_ko.arb)로 옮겨야 한다');
  });

  test('모든 키에 번역가용 설명이 있다', () {
    final arb = jsonDecode(File('lib/l10n/app_ko.arb').readAsStringSync())
        as Map<String, dynamic>;
    final missing = [
      for (final key in arb.keys)
        if (!key.startsWith('@') &&
            ((arb['@$key'] as Map?)?['description'] as String? ?? '').isEmpty)
          key,
    ];
    expect(missing, isEmpty);
  });
}
