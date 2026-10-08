import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'keycap.dart';
import 'play_instrument.dart';

/// 놀이 고르기 — 놀이를 그린 동그란 버튼 셋. 글자 없이 그림으로 고른다.
class InstrumentPicker extends StatelessWidget {
  const InstrumentPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final PlayInstrument selected;
  final ValueChanged<PlayInstrument> onSelect;

  static const double size = 60;

  /// 버튼 [i]의 위젯 키. 테스트가 찾는 데 쓴다.
  static ValueKey<String> keyFor(PlayInstrument i) =>
      ValueKey('instrument-${i.name}');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final i in PlayInstrument.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _Button(
              key: keyFor(i),
              instrument: i,
              selected: i == selected,
              onTap: () => onSelect(i),
            ),
          ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    super.key,
    required this.instrument,
    required this.selected,
    required this.onTap,
  });

  final PlayInstrument instrument;
  final bool selected;
  final VoidCallback onTap;

  Widget _picture(double side) => switch (instrument) {
    PlayInstrument.moktak => Image.asset(
      'assets/play/thumb_moktak.webp',
      width: side,
      height: side,
    ),
    PlayInstrument.singingBowl => Image.asset(
      'assets/play/thumb_singing_bowl.webp',
      width: side,
      height: side,
    ),
    PlayInstrument.keycap => KeycapIcon(size: side),
  };

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    const size = InstrumentPicker.size;
    return Semantics(
      button: true,
      selected: selected,
      label: instrument.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1 : 0.88,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: selected ? 1 : 0.6),
              border: Border.all(
                color: selected ? Tokens.saffron : fg.withValues(alpha: 0.1),
                width: selected ? 2.5 : 1,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: Tokens.saffron.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: selected ? 1 : 0.6,
              duration: const Duration(milliseconds: 160),
              child: _picture(size * 0.66),
            ),
          ),
        ),
      ),
    );
  }
}
