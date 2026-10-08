import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/time_utils.dart';

/// 걸음 수를 기기 건강 데이터에서 읽는다.
/// Android 는 Health Connect, iOS 는 건강(HealthKit). 앱이 직접 세지 않는다 —
/// 앱이 꺼져 있던 날의 걸음도 달력에 나와야 하기 때문이다.
abstract class StepSource {
  /// 이 기기에서 건강 데이터를 읽을 수 있는가.
  Future<StepAvailability> availability();

  /// 걸음 수 읽기 권한을 묻는다. 허락하면 true.
  Future<bool> requestAccess();

  /// [from]~[to] (날짜만 본다) 하루하루의 걸음 수. 키는 yyyy-MM-dd.
  /// 읽지 못한 날은 빠진다.
  Future<Map<String, int>> dailySteps(DateTime from, DateTime to);
}

enum StepAvailability {
  available,

  /// Android 에 Health Connect 가 없거나 업데이트가 필요하다.
  needsInstall,

  /// 데스크톱·웹 등 건강 데이터가 없는 곳.
  unsupported,
}

class HealthStepSource implements StepSource {
  final Health _health = Health();
  bool _configured = false;

  static const _types = [HealthDataType.STEPS];
  static const _read = [HealthDataAccess.READ];

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<StepAvailability> availability() async {
    if (!_mobile) return StepAvailability.unsupported;
    await _configure();
    if (Platform.isAndroid && !await _health.isHealthConnectAvailable()) {
      return StepAvailability.needsInstall;
    }
    return StepAvailability.available;
  }

  /// Health Connect 설치 화면(스토어)을 연다. Android 에서만.
  Future<void> installHealthConnect() => _health.installHealthConnect();

  @override
  Future<bool> requestAccess() async {
    if (await availability() != StepAvailability.available) return false;
    try {
      return await _health.requestAuthorization(_types, permissions: _read);
    } catch (e) {
      debugPrint('걸음 수 권한 요청 실패: $e');
      return false;
    }
  }

  @override
  Future<Map<String, int>> dailySteps(DateTime from, DateTime to) async {
    if (await availability() != StepAvailability.available) return {};
    final first = DateTime(from.year, from.month, from.day);
    final last = DateTime(to.year, to.month, to.day);
    final days = [
      for (var d = first; !d.isAfter(last); d = DateTime(d.year, d.month, d.day + 1))
        d,
    ];
    final counts = await Future.wait(days.map((d) async {
      try {
        return await _health.getTotalStepsInInterval(
          d,
          DateTime(d.year, d.month, d.day + 1),
        );
      } catch (e) {
        debugPrint('걸음 수 읽기 실패 ${localDateKey(d)}: $e');
        return null;
      }
    }));
    return {
      for (var i = 0; i < days.length; i++)
        if (counts[i] != null) localDateKey(days[i]): counts[i]!,
    };
  }
}
