import 'package:bucheo_handsome/app/providers.dart';
import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/data/db/database.dart';
import 'package:bucheo_handsome/data/repositories/session_repository.dart';
import 'package:bucheo_handsome/features/session/screens/session_repeat_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 번뇌를 적고 3분 엎어 둔 세션 하나를 남긴다.
Future<Session> _session(
  SessionRepository repo,
  DateTime at,
  String? worry,
) async {
  final s = await repo.start(
    startedAt: at,
    targetSec: 180,
    detection: 'B',
    audioOn: false,
    worryText: worry,
    repeatFlag: true,
  );
  await repo.finish(
    sessionId: s.id,
    endedAt: at.add(const Duration(minutes: 3)),
    practicedSec: 180,
    completed: true,
  );
  return s;
}

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  group('지난번 그 얘기 — 이전 번뇌', () {
    test('방금 끝낸 세션의 번뇌는 「지난번」이 아니다', () async {
      await _session(repo, DateTime(2026, 10, 6, 9), '팀장이 또 뭐라 했다');
      final now = await _session(repo, DateTime(2026, 10, 7, 9), '오늘은 잠이 안 온다');

      final list = await repo.previousWorries(excludeId: now.id);
      expect(list.first.worryText, '팀장이 또 뭐라 했다');
      expect(list.any((s) => s.id == now.id), isFalse);
    });

    test('번뇌를 안 적은 세션은 건너뛰고, 그 전에 적은 번뇌를 꺼낸다', () async {
      await _session(repo, DateTime(2026, 10, 5, 9), '돈이 걱정이다');
      await _session(repo, DateTime(2026, 10, 6, 9), null);
      final now = await _session(repo, DateTime(2026, 10, 7, 9), '또 돈이다');

      final list = await repo.previousWorries(excludeId: now.id);
      expect(list.first.worryText, '돈이 걱정이다');
    });

    test('처음 적은 번뇌라면 지난번 번뇌는 없다', () async {
      final now = await _session(repo, DateTime(2026, 10, 7, 9), '처음 적는다');
      expect(await repo.previousWorries(excludeId: now.id), isEmpty);
    });

    test('최근 것부터', () async {
      await _session(repo, DateTime(2026, 10, 1, 9), '첫째');
      await _session(repo, DateTime(2026, 10, 2, 9), '둘째');
      await _session(repo, DateTime(2026, 10, 3, 9), '셋째');
      final list = await repo.previousWorries();
      expect(list.map((s) => s.worryText), ['셋째', '둘째', '첫째']);
    });
  });

  group('지난번 그 얘기 — 화면', () {
    Future<void> pumpRepeat(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SessionRepeatScreen(),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }

    testWidgets('이전 번뇌가 있으면 보여 주고 지금은 어떤지 묻는다', (tester) async {
      await tester.runAsync(
        () => _session(repo, DateTime(2026, 10, 6, 9), '팀장이 또 뭐라 했다'),
      );
      await pumpRepeat(tester);

      expect(find.text('팀장이 또 뭐라 했다'), findsOneWidget);
      expect(find.text('요즘은 어떤가?'), findsOneWidget);
      final done = find.widgetWithText(FilledButton, '됐다');
      expect(
        tester.widget<FilledButton>(done).onPressed,
        isNull,
        reason: '고르기 전에는 못 나간다',
      );

      await tester.tap(find.text('조금 나아졌다'));
      await tester.pump();
      expect(tester.widget<FilledButton>(done).onPressed, isNotNull);
    });

    testWidgets('이전 번뇌가 없으면 묻지 않고 바로 나갈 수 있다', (tester) async {
      await pumpRepeat(tester);

      expect(find.textContaining('지난번에 적어 둔 번뇌가 없다'), findsOneWidget);
      expect(find.text('요즘은 어떤가?'), findsNothing);
      expect(find.text('조금 나아졌다'), findsNothing);
      final done = find.widgetWithText(FilledButton, '됐다');
      expect(tester.widget<FilledButton>(done).onPressed, isNotNull);
    });
  });
}
