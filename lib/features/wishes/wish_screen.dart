import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wish_store.dart';

class WishScreen extends ConsumerStatefulWidget {
  const WishScreen({super.key});
  @override
  ConsumerState<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends ConsumerState<WishScreen> {
  final controller = TextEditingController();
  bool saving = false;
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final store = await ref.read(wishStoreProvider.future);
      await store.add(controller.text);
      ref.invalidate(wishCountProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('소원을 연등에 달았어요.')));
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = '저장하지 못했어요. 다시 시도해 주세요.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('소원 빌기')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '모든 이의 소원이\n이루어지기를',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              enabled: !saving,
              maxLength: 120,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              minLines: 8,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '마음속 소원을 적어 보세요',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            const Text('소원은 이 기기에 저장됩니다.', textAlign: TextAlign.center),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving || controller.text.trim().isEmpty ? null : save,
              child: Text(saving ? '소원을 다는 중…' : '작성 완료'),
            ),
          ],
        ),
      ),
    ),
  );
}
