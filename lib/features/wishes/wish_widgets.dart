import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/router.dart';
import '../../l10n/l10n.dart';

import 'package:go_router/go_router.dart';

import 'wish_store.dart';
import 'lantern_canopy.dart';

class WishLanterns extends StatelessWidget {
  const WishLanterns({super.key, this.height = 340, this.topInset = 0});
  final double height;
  final double topInset;

  @override
  Widget build(BuildContext context) => LanternCanopy(
    height: height,
    topInset: topInset,
    onTap: () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _WishReader(),
    ),
  );
}

class WishEntry extends ConsumerWidget {
  const WishEntry({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(wishCountProvider);
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            count.when(
              data: (n) => l10n.wishesEntryMyCount(n),
              loading: () => l10n.wishesEntryLoading,
              error: (_, _) => l10n.wishesEntryLoadError,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextButton.icon(
          onPressed: () => context.push(Routes.wish),
          icon: const Icon(Icons.volunteer_activism_outlined, size: 20),
          label: Text(l10n.wishesEntryWriteButton),
        ),
      ],
    );
  }
}

class _WishReader extends ConsumerStatefulWidget {
  const _WishReader();
  @override
  ConsumerState<_WishReader> createState() => _WishReaderState();
}

class _WishReaderState extends ConsumerState<_WishReader> {
  final random = Random();
  late String text = pickWish(exampleWishes, null, random);
  bool mine = false;
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(wishStoreProvider).value;
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 36, child: Divider(thickness: 4)),
              const SizedBox(height: 16),
              SvgPicture.asset('assets/wishes/lantern.svg', height: 90),
              const SizedBox(height: 16),
              Text(
                mine ? l10n.wishesReaderMineLabel : l10n.wishesReaderExampleLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: const Color(0xFF41382E)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.wishesReaderOthersNote,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => setState(() {
                  text = pickWish(
                    mine ? store!.wishes : exampleWishes,
                    text,
                    random,
                  );
                }),
                child: Text(l10n.wishesReaderNext),
              ),
              if (store != null && store.wishes.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() {
                    mine = !mine;
                    text = pickWish(
                      mine ? store.wishes : exampleWishes,
                      null,
                      random,
                    );
                  }),
                  child: Text(
                    mine
                        ? l10n.wishesReaderShowExamples
                        : l10n.wishesReaderShowMine,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
