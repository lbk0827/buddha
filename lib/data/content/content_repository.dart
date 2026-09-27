import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/flags.dart';
import 'models.dart';

const int kSupportedSchemaVersion = 1;

/// 번들 JSON 로더. schemaVersion이 맞지 않거나 파일이 깨졌으면
/// 오류 화면을 띄우지 않고 빈 풀로 계속 간다 (PRD 버전 관리).
class ContentBundle {
  final List<DialogueItem> dialogues;
  final List<RootItem> roots;
  final TestContent? test;
  final SafetyContent safety;
  final List<String> loadErrors;

  ContentBundle({
    required this.dialogues,
    required this.roots,
    required this.test,
    required this.safety,
    required this.loadErrors,
  });

  /// 공개 뿌리만. reviewStatus != public은 어떤 경로로도 렌더되지 않는다 (FR-5.1).
  late final List<RootItem> publicRoots =
      roots.where((r) => r.isPublic).toList(growable: false);

  /// 공개 콘텐츠 5건 미만이면 뿌리 링크 전체 비활성 (FR-5.5).
  bool get rootsLinkEnabled =>
      Flags.rootsEnabled && publicRoots.length >= Flags.rootsMinPublic;

  RootItem? rootById(String? id) {
    if (id == null) return null;
    for (final r in publicRoots) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<DialogueItem> forScreen(String screen) =>
      dialogues.where((d) => d.screen == screen).toList(growable: false);

  List<DialogueItem> forPool(String pool) =>
      dialogues.where((d) => d.pool == pool).toList(growable: false);
}

class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  ContentBundle? _cached;

  Future<ContentBundle> load({bool force = false}) async {
    if (_cached != null && !force) return _cached!;
    final errors = <String>[];

    final dialogues = await _loadList(
      'assets/content/dialogues.json',
      DialogueItem.fromJson,
      errors,
    );
    final roots = await _loadList(
      'assets/content/roots.json',
      RootItem.fromJson,
      errors,
    );
    final test = await _loadObject(
      'assets/content/test.json',
      TestContent.fromJson,
      errors,
    );
    final safety = await _loadObject(
          'assets/content/safety.json',
          SafetyContent.fromJson,
          errors,
        ) ??
        SafetyContent.fallback();

    return _cached = ContentBundle(
      dialogues: dialogues,
      roots: roots,
      test: test,
      safety: safety,
      loadErrors: errors,
    );
  }

  Future<Map<String, dynamic>?> _readJson(
      String path, List<String> errors) async {
    try {
      final raw = await _bundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        errors.add('$path: 최상위가 객체가 아니다');
        return null;
      }
      final version = (decoded['schemaVersion'] as num?)?.toInt();
      if (version != kSupportedSchemaVersion) {
        errors.add('$path: schemaVersion $version, 지원 $kSupportedSchemaVersion');
        return null;
      }
      return decoded;
    } catch (e) {
      errors.add('$path: $e');
      debugPrint('content load failed: $path — $e');
      return null;
    }
  }

  Future<List<T>> _loadList<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
    List<String> errors,
  ) async {
    final json = await _readJson(path, errors);
    if (json == null) return const [];
    final items = json['items'];
    if (items is! List) {
      errors.add('$path: items 배열 없음');
      return const [];
    }
    final out = <T>[];
    for (final item in items) {
      try {
        out.add(parse((item as Map).cast<String, dynamic>()));
      } catch (e) {
        errors.add('$path: 항목 파싱 실패 — $e');
      }
    }
    return out;
  }

  Future<T?> _loadObject<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
    List<String> errors,
  ) async {
    final json = await _readJson(path, errors);
    if (json == null) return null;
    try {
      return parse(json);
    } catch (e) {
      errors.add('$path: 파싱 실패 — $e');
      return null;
    }
  }
}
