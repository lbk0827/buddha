import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/avatar/avatar_equip.dart';
import '../db/database.dart';

/// 설정 키 (FR-8.3).
class SettingKeys {
  /// 'none' | 'minimal' | 'default'
  static const voice = 'voice';
  static const sambaeRitual = 'sambae';

  /// 'timer' | 'sensorA' | 'sensorC'
  static const detection = 'detection';
  static const hideNumbers = 'hideNumbers';
  static const revisitNotifications = 'revisitNotifications';
}

/// 동의 키. 각 기능 첫 사용 시점에 1회 요청 (FR-1.5).
class ConsentKeys {
  static const recordStorage = 'recordStorage';
  static const notifications = 'notifications';
  static const analytics = 'analytics';
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Stream<Profile> watch() =>
      (_db.select(_db.profiles)..where((t) => t.id.equals(1)))
          .watchSingleOrNull()
          .asyncMap((p) async => p ?? await ensure());

  Future<Profile> ensure() async {
    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existing != null) return existing;
    await _db.into(_db.profiles).insert(
          ProfilesCompanion.insert(firstLaunchAt: Value(DateTime.now())),
        );
    return (_db.select(_db.profiles)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> _write(ProfilesCompanion c) =>
      (_db.update(_db.profiles)..where((t) => t.id.equals(1))).write(c);

  Map<String, dynamic> settingsOf(Profile p) => _decode(p.settingsJson);
  Map<String, dynamic> consentsOf(Profile p) => _decode(p.consentsJson);

  Map<String, dynamic> _decode(String raw) {
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> setSetting(String key, Object? value) async {
    final p = await ensure();
    final s = settingsOf(p)..[key] = value;
    await _write(ProfilesCompanion(settingsJson: Value(jsonEncode(s))));
  }

  /// 동의는 시각과 함께 남긴다. 철회하면 null.
  Future<void> setConsent(String key, bool granted) async {
    final p = await ensure();
    final c = consentsOf(p);
    if (granted) {
      c[key] = DateTime.now().toIso8601String();
    } else {
      c.remove(key);
    }
    await _write(ProfilesCompanion(consentsJson: Value(jsonEncode(c))));
  }

  Future<bool> hasConsent(String key) async =>
      consentsOf(await ensure())[key] != null;

  Future<void> setCharacter(String character) =>
      _write(ProfilesCompanion(character: Value(character)));

  /// 앞 글자 변경 시 뒷 글자는 유지된다 (FR-4.8).
  Future<void> setDharmaFirst(String? first) =>
      _write(ProfilesCompanion(dharmaFirst: Value(first)));

  Future<void> markCharacterOnboardShown() =>
      _write(const ProfilesCompanion(characterOnboardShown: Value(true)));

  Future<void> touchVisit(DateTime at) =>
      _write(ProfilesCompanion(lastVisitAt: Value(at)));

  Future<void> clearLeaves(String dateKey) =>
      _write(ProfilesCompanion(leavesClearedDate: Value(dateKey)));

  Future<void> setRecoveryPref(String? pref) =>
      _write(ProfilesCompanion(recoveryPref: Value(pref)));

  AvatarEquip equipOf(Profile p) {
    final e = AvatarEquip.decode(p.equipJson);
    return e.isEmpty ? kDefaultEquip : e;
  }

  Set<String> ownedItemsOf(Profile p) {
    try {
      final d = jsonDecode(p.ownedItemsJson);
      if (d is! List) return {};
      return d.whereType<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> setEquip(AvatarEquip equip) =>
      _write(ProfilesCompanion(equipJson: Value(equip.encode())));

  /// 공덕을 치르고 옷장 아이템을 연다. 공덕이 모자라면 false.
  Future<bool> buyItem(WardrobeItem item) async {
    final p = await ensure();
    final owned = ownedItemsOf(p);
    if (owned.contains(item.id)) return true;
    if (p.merit < item.meritCost) return false;

    owned.add(item.id);
    await _write(ProfilesCompanion(
      ownedItemsJson: Value(jsonEncode(owned.toList())),
      merit: Value(p.merit - item.meritCost),
    ));
    return true;
  }

  /// 회복 기본값은 첫 3회만 적용한다 (FR-6.5).
  Future<void> bumpDefaultsApplied() async {
    final p = await ensure();
    await _write(
        ProfilesCompanion(defaultsAppliedCount: Value(p.defaultsAppliedCount + 1)));
  }
}
