import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';
import 'token_catalog.dart';

/// 「증표」 탭 — 비움의 증표.
/// 돈으로는 못 산다. 수행 이력이 열쇠다.
class TokensScreen extends ConsumerStatefulWidget {
  const TokensScreen({super.key});

  @override
  ConsumerState<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends ConsumerState<TokensScreen> {
  /// 0 전체 · 1 해제됨 · 2 시즌
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeStateProvider);
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: home.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) {
          final unlockedCount = kTokenCatalog
              .where((t) => t.isUnlocked(state.stats))
              .length;

          final visible = kTokenCatalog.where((t) {
            if (_filter == 1) return t.isUnlocked(state.stats);
            if (_filter == 2) return t.group == TokenGroup.season;
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                Tokens.gutter, 24, Tokens.gutter, kHudClearance),
            children: [
              Text('비움의 증표', style: text.displayMedium),
              const SizedBox(height: 6),
              Text(
                '돈으로만은 못 산다. 수행 이력이 열쇠다.',
                style:
                    text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _FilterChip(
                    label: '전체',
                    selected: _filter == 0,
                    onTap: () => setState(() => _filter = 0),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '해제됨 $unlockedCount',
                    selected: _filter == 1,
                    onTap: () => setState(() => _filter = 1),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '시즌',
                    selected: _filter == 2,
                    onTap: () => setState(() => _filter = 2),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
                children: [
                  for (final t in visible)
                    _TokenCard(token: t, stats: state.stats),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF221F1A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: fg.withValues(alpha: 0.08)),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: fg.withValues(alpha: 0.6)),
                    children: [
                      const TextSpan(text: '해제된 증표는 프로필에 박힌다. 산 사람보다 '),
                      TextSpan(
                        text: '해낸 사람',
                        style: TextStyle(
                            color: fg, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '이 보이게.'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Tokens.ink : Colors.transparent,
          border: Border.all(
              color: selected ? Tokens.ink : fg.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Tokens.ivory : fg,
            fontWeight: selected ? FontWeight.w700 : null,
          ),
        ),
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.token, required this.stats});

  final TokenDef token;
  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    final unlocked = token.isUnlocked(stats);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;
    final season = token.group == TokenGroup.season;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: season
            ? Tokens.ink
            : (isDark ? const Color(0xFF221F1A) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked && !season
              ? Tokens.saffron
              : fg.withValues(alpha: 0.07),
          width: unlocked && !season ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: season
                    ? Tokens.seal
                    : (unlocked
                        ? const Color(0xFFFBE4C8)
                        : const Color(0xFFE3EBE5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      size: const Size(64, 64),
                      painter: _BeadsPainter(
                        dim: !unlocked,
                        color: season ? const Color(0xFFE6C56A) : null,
                      ),
                    ),
                  ),
                  if (!unlocked)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Tokens.ink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline,
                            size: 14, color: Tokens.ivory),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            token.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: season ? Tokens.ivory : fg,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            unlocked ? '해제됨 · ${token.requirementLabel}' : token.requirementLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: unlocked ? FontWeight.w700 : null,
              color: unlocked
                  ? const Color(0xFF2E7D4F)
                  : (season
                      ? const Color(0xFFA39B90)
                      : fg.withValues(alpha: 0.55)),
            ),
          ),
          if (!unlocked && token.goal > 0) ...[
            const SizedBox(height: 8),
            Text(
              token.progressLabel(stats),
              style:
                  TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: token.ratio(stats),
                minHeight: 6,
                backgroundColor: fg.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Tokens.temple),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BeadsPainter extends CustomPainter {
  _BeadsPainter({required this.dim, this.color});
  final bool dim;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final paint = Paint()
      ..color = (color ?? const Color(0xFF8B5E3C))
          .withValues(alpha: dim ? 0.35 : 1);
    for (var i = 0; i < 18; i++) {
      final a = (i / 18) * 2 * math.pi - math.pi / 2;
      final p = center + Offset(radius * math.cos(a), radius * math.sin(a));
      canvas.drawCircle(p, i == 0 ? 5.5 : 4, paint);
    }
  }

  @override
  bool shouldRepaint(_BeadsPainter old) => old.dim != dim || old.color != color;
}
