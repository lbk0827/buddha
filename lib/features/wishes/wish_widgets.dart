import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/router.dart';

import 'package:go_router/go_router.dart';

import 'wish_store.dart';
import 'lantern_canopy.dart';

class WishLanterns extends StatelessWidget {
  const WishLanterns({super.key, this.height = 340});
  final double height;

  @override
  Widget build(BuildContext context) => LanternCanopy(
    height: height,
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
    return Row(
      children: [
        Expanded(
          child: Text(
            count.when(
              data: (n) => '내가 올린 소원 $n개',
              loading: () => '소원을 불러오는 중',
              error: (_, _) => '소원을 불러오지 못했어요',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextButton.icon(
          onPressed: () => context.push(Routes.wish),
          icon: const Icon(Icons.volunteer_activism_outlined, size: 20),
          label: const Text('소원 빌기'),
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
                mine ? '내 소원' : '예시 소원',
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
              const Text(
                '다른 사람의 소원은 공유 기능 연결 후 볼 수 있어요.',
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
                child: const Text('다른 소원 보기'),
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
                  child: Text(mine ? '예시 소원 보기' : '내 소원 보기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
