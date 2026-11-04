import 'package:flutter/material.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class SocialLoginSection extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;

  const SocialLoginSection({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Wrap instead of Row: on narrow screens, large text scale or longer
        // translations the action moves to the next line instead of
        // overflowing.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              promptText,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
