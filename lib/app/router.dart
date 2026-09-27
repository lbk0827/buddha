import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/goods/goods_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/character_onboard_screen.dart';
import '../features/records/records_screen.dart';
import '../features/roots/root_screen.dart';
import '../features/safety/safety_screen.dart';
import '../features/session/screens/session_done_screen.dart';
import '../features/session/screens/session_interrupt_screen.dart';
import '../features/session/screens/session_ready_screen.dart';
import '../features/session/screens/session_repeat_screen.dart';
import '../features/session/screens/session_running_screen.dart';
import '../features/session/screens/session_setup_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/temple/temple_screen.dart';
import '../features/test/screens/checkin_screen.dart';
import '../features/test/screens/test_intro_screen.dart';
import '../features/test/screens/test_question_screen.dart';
import '../features/test/screens/test_result_screen.dart';
import '../features/profile/profile_screen.dart';

class Routes {
  static const home = '/';
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
  static const goods = '/goods';
  static const settings = '/settings';
  static const characterOnboard = '/onboard/character';

  static String root(String id) => '/roots/$id';
  static String question(int n) => '/test/q/$n';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
          path: Routes.sessionSetup,
          builder: (_, state) => SessionSetupScreen(
                prefillWorry: state.uri.queryParameters['prefillWorry'] == '1',
                forcedLengthSec:
                    int.tryParse(state.uri.queryParameters['len'] ?? ''),
                forceAudio: state.uri.queryParameters['audio'] == '1',
              )),
      GoRoute(
          path: Routes.sessionReady,
          builder: (_, _) => const SessionReadyScreen()),
      GoRoute(
          path: Routes.sessionRunning,
          builder: (_, _) => const SessionRunningScreen()),
      GoRoute(
          path: Routes.sessionInterrupt,
          builder: (_, _) => const SessionInterruptScreen()),
      GoRoute(
          path: Routes.sessionDone,
          builder: (_, _) => const SessionDoneScreen()),
      GoRoute(
          path: Routes.sessionRepeat,
          builder: (_, _) => const SessionRepeatScreen()),
      GoRoute(path: Routes.safety, builder: (_, _) => const SafetyScreen()),
      GoRoute(path: Routes.temple, builder: (_, _) => const TempleScreen()),
      GoRoute(path: Routes.records, builder: (_, _) => const RecordsScreen()),
      GoRoute(path: Routes.test, builder: (_, _) => const TestIntroScreen()),
      GoRoute(
          path: '/test/q/:n',
          builder: (_, state) => TestQuestionScreen(
              index: int.tryParse(state.pathParameters['n'] ?? '0') ?? 0)),
      GoRoute(
          path: Routes.testResult,
          builder: (_, _) => const TestResultScreen()),
      GoRoute(path: Routes.checkin, builder: (_, _) => const CheckinScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: Routes.goods, builder: (_, _) => const GoodsScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
          path: Routes.characterOnboard,
          builder: (_, _) => const CharacterOnboardScreen()),
      GoRoute(
          path: '/roots/:id',
          builder: (_, state) =>
              RootScreen(rootId: state.pathParameters['id'] ?? '')),
    ],
  );
});
