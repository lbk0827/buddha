import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/avatar/wardrobe_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/character_onboard_screen.dart';
import '../features/onboarding/ordination_screen.dart';
import '../features/play/play_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/records/records_screen.dart';
import '../features/roots/root_screen.dart';
import '../features/safety/safety_screen.dart';
import '../features/seonsa/seonsa_screen.dart';
import '../features/session/screens/session_done_screen.dart';
import '../features/session/screens/session_interrupt_screen.dart';
import '../features/session/screens/session_ready_screen.dart';
import '../features/session/screens/session_repeat_screen.dart';
import '../features/session/screens/session_running_screen.dart';
import '../features/session/screens/session_setup_screen.dart';
import '../features/settings/credits_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/temple/temple_screen.dart';
import '../features/test/screens/checkin_screen.dart';
import '../features/test/screens/test_intro_screen.dart';
import '../features/test/screens/test_question_screen.dart';
import '../features/test/screens/test_result_screen.dart';
import '../features/tokens/tokens_screen.dart';
import '../features/worry/burn_screen.dart';
import '../features/wishes/wish_screen.dart';
import '../features/wishes/wish_tab_screen.dart';

class Routes {
  // 하단 HUD 네 탭
  static const home = '/';
  static const play = '/play';
  static const seonsa = '/seonsa';
  static const wishes = '/wishes';

  // 증표 — HUD 밖. 상단바 버튼으로 연다.
  static const tokens = '/tokens';

  // 놀이
  static const burn = '/play/burn';
  static const wish = '/wish';

  // 수행
  static const sessionSetup = '/session/setup';
  static const sessionReady = '/session/ready';
  static const sessionRunning = '/session/running';
  static const sessionInterrupt = '/session/interrupt';
  static const sessionDone = '/session/done';
  static const sessionRepeat = '/session/repeat';

  static const safety = '/safety';
  static const temple = '/temple';
  static const records = '/records';
  static const test = '/test';
  static const testResult = '/test/result';
  static const checkin = '/checkin';
  static const profile = '/profile';
  static const settings = '/settings';
  static const credits = '/settings/credits';
  static const wardrobe = '/wardrobe';
  static const ordination = '/onboard/ordination';
  static const characterOnboard = '/onboard/character';

  static String root(String id) => '/roots/$id';
  static String question(int n) => '/test/q/$n';
}

final _shellKey = GlobalKey<NavigatorState>();
final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      // 하단 HUD가 붙는 네 탭.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: Routes.wardrobe,
            builder: (_, _) => const WardrobeScreen(),
          ),
          GoRoute(path: Routes.play, builder: (_, _) => const PlayScreen()),
          GoRoute(path: Routes.seonsa, builder: (_, _) => const SeonsaScreen()),
          GoRoute(
            path: Routes.wishes,
            builder: (_, _) => const WishTabScreen(),
          ),
        ],
      ),

      // 놀이 — HUD 없이 전체 화면
      GoRoute(path: Routes.burn, builder: (_, _) => const BurnScreen()),
      GoRoute(path: Routes.wish, builder: (_, _) => const WishScreen()),
      GoRoute(path: Routes.tokens, builder: (_, _) => const TokensScreen()),

      GoRoute(
        path: Routes.sessionSetup,
        builder: (_, state) => SessionSetupScreen(
          prefillWorry: state.uri.queryParameters['prefillWorry'] == '1',
          forcedLengthSec: int.tryParse(state.uri.queryParameters['len'] ?? ''),
          forceAudio: state.uri.queryParameters['audio'] == '1',
        ),
      ),
      GoRoute(
        path: Routes.sessionReady,
        builder: (_, _) => const SessionReadyScreen(),
      ),
      GoRoute(
        path: Routes.sessionRunning,
        builder: (_, _) => const SessionRunningScreen(),
      ),
      GoRoute(
        path: Routes.sessionInterrupt,
        builder: (_, _) => const SessionInterruptScreen(),
      ),
      GoRoute(
        path: Routes.sessionDone,
        builder: (_, _) => const SessionDoneScreen(),
      ),
      GoRoute(
        path: Routes.sessionRepeat,
        builder: (_, _) => const SessionRepeatScreen(),
      ),

      GoRoute(path: Routes.safety, builder: (_, _) => const SafetyScreen()),
      GoRoute(path: Routes.temple, builder: (_, _) => const TempleScreen()),
      GoRoute(path: Routes.records, builder: (_, _) => const RecordsScreen()),
      GoRoute(path: Routes.test, builder: (_, _) => const TestIntroScreen()),
      GoRoute(
        path: '/test/q/:n',
        builder: (_, state) => TestQuestionScreen(
          index: int.tryParse(state.pathParameters['n'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        path: Routes.testResult,
        builder: (_, _) => const TestResultScreen(),
      ),
      GoRoute(path: Routes.checkin, builder: (_, _) => const CheckinScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.credits, builder: (_, _) => const CreditsScreen()),
      GoRoute(
        path: Routes.ordination,
        builder: (_, _) => const OrdinationScreen(),
      ),
      GoRoute(
        path: Routes.characterOnboard,
        builder: (_, _) => const CharacterOnboardScreen(),
      ),
      GoRoute(
        path: '/roots/:id',
        builder: (_, state) =>
            RootScreen(rootId: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});
