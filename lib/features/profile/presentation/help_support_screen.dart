import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<(String, String)> _faqs = <(String, String)>[
    (
      'How do I earn XP?',
      'Play games, complete missions and unlock achievements while signed '
          'in. XP is awarded by our servers, so it may take a moment to show '
          'up in your profile.',
    ),
    (
      'Why didn\'t my progress save?',
      'XP, streaks, favorites and achievements are only saved to your '
          'account while you are signed in.',
    ),
    (
      'What are missions?',
      'Missions are challenges that refresh on a schedule. Open the Missions '
          'tab to see what is active and how much XP each one rewards.',
    ),
    (
      'A game won\'t load. What can I do?',
      'Games are provided by third-party publishers and need a stable '
          'internet connection. Go back and open the game again, or try '
          'another game.',
    ),
    (
      'How do I sign out?',
      'Open Account Settings from your profile and tap Sign Out.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _faqs.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final (question, answer) = _faqs[index];
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
