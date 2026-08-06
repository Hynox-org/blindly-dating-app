import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';

/// Picks the language the *app UI* is shown in. Not to be confused with
/// `LanguageSelectionScreen`, which edits the languages a user speaks.
class AppLanguageScreen extends ConsumerWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(localeProvider)?.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.appLanguageTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RadioGroup<String?>(
        groupValue: selected,
        onChanged: (code) => ref
            .read(localeProvider.notifier)
            .set(code == null ? null : Locale(code)),
        child: ListView(
          children: [
            RadioListTile<String?>(
              value: null,
              title: Text(l10n.systemDefault),
              activeColor: const Color(0xFF414833),
            ),
            for (final entry in appLanguages.entries)
              RadioListTile<String?>(
                value: entry.key,
                title: Text(entry.value),
                activeColor: const Color(0xFF414833),
              ),
          ],
        ),
      ),
    );
  }
}
