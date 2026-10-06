import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/time_utils.dart';
import '../session_controller.dart';
import '../session_timing.dart';

/// 중단 선택. 이 화면 체류 시간은 수행 시간에서 제외된다 (FR-2.5).
/// 60초 무응답이면 중단 종료.
class SessionInterruptScreen extends ConsumerStatefulWidget {
  const SessionInterruptScreen({super.key});

  @override
  ConsumerState<SessionInterruptScreen> createState() =>
      _SessionInterruptScreenState();
}

class _SessionInterruptScreenState
    extends ConsumerState<SessionInterruptScreen> {
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _timeout = Timer(kInterruptChoiceTimeout, () => _stop(timeout: true));
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  Future<void> _resume() async {
    _timeout?.cancel();
    await ref.read(analyticsProvider).log('interrupt_choice', {'choice': 'resume'});
    await ref.read(sessionControllerProvider.notifier).resumeFromInterrupt();
    if (!mounted) return;
    context.pop();
  }

  Future<void> _stop({bool timeout = false}) async {
    _timeout?.cancel();
    await ref
        .read(analyticsProvider)
        .log('interrupt_choice', {'choice': timeout ? 'timeout' : 'stop'});
    await ref.read(sessionControllerProvider.notifier).stopHere();
    if (!mounted) return;
    context.pushReplacement(Routes.sessionDone);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    // 체류 구간이 열려 있으므로 여기 값은 더 늘지 않는다.
    final practiced = state.practicedAt(DateTime.now());

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Tokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text('${formatDuration(practiced)} 쉬었다.',
                    style: Theme.of(context).textTheme.displayMedium),
                const Spacer(),
                FilledButton(
                  onPressed: _resume,
                  child: const Text('더 쉴래'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _stop(),
                  child: const Text('오늘은 여기까지'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
