import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/time_utils.dart';
import '../session_controller.dart';

/// 검은 화면 + 최소 정보. 기본 설정에서는 소리·진동이 없다 (FR-2.4).
class SessionRunningScreen extends ConsumerStatefulWidget {
  const SessionRunningScreen({super.key});

  @override
  ConsumerState<SessionRunningScreen> createState() =>
      _SessionRunningScreenState();
}

class _SessionRunningScreenState extends ConsumerState<SessionRunningScreen>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 상태바만 검게 맞춘다. 몰입 모드는 쓰지 않는다 —
    // 안드로이드가 "Viewing full screen" 안내를 띄워 수행을 방해한다.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Tokens.runningBg,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Tokens.runningBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasBackgrounded = true;
      return;
    }
    if (state != AppLifecycleState.resumed || !_wasBackgrounded) return;
    _wasBackgrounded = false;
    _onReturn();
  }

  /// 앱 전면 복귀 시 타임스탬프로 경과를 계산한다 (FR-2.5).
  Future<void> _onReturn() async {
    final controller = ref.read(sessionControllerProvider.notifier);
    final session = ref.read(sessionControllerProvider);
    if (session.phase != SessionPhase.running) return;

    if (session.reachedTargetAt(DateTime.now())) {
      await controller.complete();
      _goDone();
    } else {
      await controller.enterInterruptChoice();
      if (!mounted || _navigated) return;
      _navigated = true;
      await context.push(Routes.sessionInterrupt);
      _navigated = false;
    }
  }

  void _goDone() {
    if (!mounted || _navigated) return;
    _navigated = true;
    context.pushReplacement(Routes.sessionDone);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);

    // 타이머가 목표에 닿으면 컨트롤러가 done으로 옮긴다.
    ref.listen(sessionControllerProvider, (prev, next) {
      if (next.phase == SessionPhase.done) _goDone();
    });

    final remaining = state.remainingAt(DateTime.now());

    return Scaffold(
      backgroundColor: Tokens.runningBg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(
                formatDuration(remaining),
                style: const TextStyle(
                  color: Tokens.runningText,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .enterInterruptChoice();
                    if (!context.mounted) return;
                    context.push(Routes.sessionInterrupt);
                  },
                  child: const Text('멈추기',
                      style: TextStyle(color: Tokens.runningText)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
