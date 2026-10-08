import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/time_utils.dart';
import '../calendar/calendar_data.dart';
import '../home/home_controller.dart';
import '../shell/tab_top_bar.dart';
import 'merit_shop.dart';

final _count = NumberFormat.decimalPattern();

/// 공덕 상점 — 공덕을 받고(하루 보상·걸음·광고) 사는(묶음) 곳.
/// 절 탭 오른쪽 아래 버튼으로 연다.
///
/// 광고와 결제는 아직 연동 전이다. 자리만 두고 「준비 중」으로 막는다.
class MeritShopScreen extends ConsumerWidget {
  const MeritShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final merit = profile?.merit ?? 0;
    final claimed = profile == null
        ? const <String>{}
        : ref.watch(profileRepositoryProvider).claimedOn(profile, todayKey());
    final linked = ref.watch(stepsLinkedProvider);
    final steps = ref.watch(todayStepsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('공덕'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Tokens.gutter),
            child: Center(child: MeritPill(merit: merit)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 8, Tokens.gutter, 32),
          children: [
            const _SectionTitle('공덕 받기'),
            _RewardRow(
              icon: Icons.wb_sunny_outlined,
              title: kDailyMerit.title,
              description: kDailyMerit.description,
              action: _ClaimButton(
                reward: kDailyMerit,
                claimed: claimed.contains(kDailyMerit.id),
                ready: true,
              ),
            ),
            _RewardRow(
              icon: Icons.ondemand_video_outlined,
              title: '광고 보고 공덕 받기',
              description: '광고 하나에 공덕 $kAdMerit. 하루 $kAdViewsPerDay번까지.',
              action: _PillButton(
                label: '0/$kAdViewsPerDay',
                onTap: () => _comingSoon(context, '광고'),
                muted: true,
              ),
            ),
            for (final r in kStepRewards)
              _RewardRow(
                icon: Icons.directions_walk,
                title: r.title,
                description: r.description,
                action: !linked
                    ? _PillButton(
                        label: '걸음 연결',
                        onTap: () => _link(context, ref),
                      )
                    : _ClaimButton(
                        reward: r,
                        claimed: claimed.contains(r.id),
                        ready: (steps ?? 0) >= r.minSteps!,
                        progress: steps == null
                            ? '걷는 중'
                            : '${_count.format(steps)}보',
                      ),
              ),
            const SizedBox(height: 28),
            const _SectionTitle('공덕 묶음'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final b in kMeritBundles)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _BundleCard(
                        bundle: b,
                        onTap: () => _comingSoon(context, '결제'),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what는 아직 준비 중이다.')));
  }

  static Future<void> _link(BuildContext context, WidgetRef ref) async {
    final ok = await linkSteps(ref);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('걸음 수를 못 읽었다. 건강 앱에서 허락하면 보인다.')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Tokens.saffron),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                        fontSize: 13, color: fg.withValues(alpha: 0.6))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          action,
        ],
      ),
    );
  }
}

/// 하루 보상 받기 버튼. 받을 수 있으면 「+30」, 받았으면 「받았다」,
/// 조건이 아직이면 [progress].
class _ClaimButton extends ConsumerStatefulWidget {
  const _ClaimButton({
    required this.reward,
    required this.claimed,
    required this.ready,
    this.progress,
  });

  final DailyMeritReward reward;
  final bool claimed;
  final bool ready;
  final String? progress;

  @override
  ConsumerState<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends ConsumerState<_ClaimButton> {
  bool _busy = false;

  Future<void> _claim() async {
    setState(() => _busy = true);
    final ok = await ref.read(profileRepositoryProvider).claimDailyMerit(
        widget.reward.id, widget.reward.merit, todayKey());
    if (ok) {
      ref.read(analyticsProvider).log('merit_reward_claimed', {
        'reward': widget.reward.id,
        'merit': widget.reward.merit,
      });
      ref.invalidate(homeStateProvider);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.claimed) {
      return const _PillButton(label: '받았다', muted: true);
    }
    if (!widget.ready) {
      return _PillButton(label: widget.progress ?? '아직', muted: true);
    }
    return _PillButton(
      label: '+${widget.reward.merit}',
      onTap: _busy ? null : _claim,
      filled: true,
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    this.onTap,
    this.filled = false,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: filled ? Tokens.saffron : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(color: fg.withValues(alpha: muted ? 0.15 : 0.3)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 84, minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: filled
                      ? Tokens.ink
                      : fg.withValues(alpha: muted ? 0.45 : 0.85),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard({required this.bundle, required this.onTap});
  final MeritBundle bundle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF221F1A)
        : Colors.white;
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: fg.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              const Icon(Icons.brightness_7, size: 30, color: Tokens.saffron),
              const SizedBox(height: 8),
              Text(_count.format(bundle.merit),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Tokens.saffron.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(bundle.priceLabel,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
