import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/flags.dart';
import '../session_controller.dart';
import '../session_timing.dart';

/// 준비 상태. 방식 B는 \[엎었다\] 버튼이 기본 (FR-2.2).
/// 60초 안에 확인이 없으면 대기로 복귀한다.
class SessionReadyScreen extends ConsumerStatefulWidget {
  const SessionReadyScreen({super.key});

  @override
  ConsumerState<SessionReadyScreen> createState() => _SessionReadyScreenState();
}

class _SessionReadyScreenState extends ConsumerState<SessionReadyScreen> {
  Timer? _timeout;

  /// 센서 방식이 켜져 있으면 5초 뒤 버튼을 노출한다 (FR-2.2 폴백).
  bool _buttonVisible = !Flags.sensorSelectable;

  @override
  void initState() {
    super.initState();
    if (!_buttonVisible) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _buttonVisible = true);
      });
    }
    _timeout = Timer(kReadyTimeout, () {
      if (!mounted) return;
      ref.read(sessionControllerProvider.notifier).abandonReady();
      context.go(Routes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다음에 하자. 급한 건 없다.')),
      );
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  Future<void> _confirm() async {
    _timeout?.cancel();
    await ref.read(sessionControllerProvider.notifier).confirmLayDown();
    if (!mounted) return;
    context.pushReplacement(Routes.sessionRunning);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = ref.watch(sessionControllerProvider).setup.targetSec ~/ 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                '$minutes분이면 된다.\n이제 폰을 엎어 두자.\n진동이 오면 시작이다.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              if (_buttonVisible)
                SizedBox(
                  height: 64,
                  child: FilledButton(
                    onPressed: _confirm,
                    child: const Text('엎어 뒀다'),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(sessionControllerProvider.notifier).abandonReady();
                    context.go(Routes.home);
                  },
                  child: const Text('다음에 하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
