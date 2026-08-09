import 'package:flutter/material.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;
  final bool isDestructiveAction;

  const ConfirmationDialogWidget({
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    required this.cancelButtonText,
    this.isDestructiveAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDestructiveAction ? Colors.red : Colors.green;
    final subtleAccent = accentColor.withAlpha(26);

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(title),
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(shape: BoxShape.circle, color: subtleAccent),
        child: Icon(
          isDestructiveAction ? Icons.warning_rounded : Icons.info_rounded,
          color: accentColor,
          size: 26,
        ),
      ),
      content: Text(
        content,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(cancelButtonText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
