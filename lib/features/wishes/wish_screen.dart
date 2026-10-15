import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
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
    final l10n = context.l10n;
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
          .showSnackBar(SnackBar(content: Text(l10n.wishesSavedSnack)));
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = l10n.wishesSaveError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.wishesWriteTitle)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.wishesWriteHeadline,
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
              decoration: InputDecoration(
                hintText: context.l10n.wishesWriteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.wishesStoredLocallyNote,
              textAlign: TextAlign.center,
            ),
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
              child: Text(
                saving
                    ? context.l10n.wishesSaving
                    : context.l10n.wishesSubmitButton,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
