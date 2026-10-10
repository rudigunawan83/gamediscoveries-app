import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static List<(String, String)> _faqs(AppLocalizations l10n) =>
      <(String, String)>[
        (l10n.helpFaqEarnXpQuestion, l10n.helpFaqEarnXpAnswer),
        (l10n.helpFaqProgressQuestion, l10n.helpFaqProgressAnswer),
        (l10n.helpFaqMissionsQuestion, l10n.helpFaqMissionsAnswer),
        (l10n.helpFaqGameLoadQuestion, l10n.helpFaqGameLoadAnswer),
        (l10n.helpFaqSignOutQuestion, l10n.helpFaqSignOutAnswer),
      ];

  @override
  Widget build(BuildContext context) {
    final faqs = _faqs(context.l10n);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileHelpSupport)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: faqs.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final (question, answer) = faqs[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.textSecondary,
              title: Text(
                question,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  answer,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
