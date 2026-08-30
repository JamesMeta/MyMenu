import 'package:flutter/material.dart';
import 'package:rankmyroast/classes/modals/group.dart';

class CreateListDialogWidget extends StatefulWidget {
  final List<Group> groups;

  const CreateListDialogWidget({super.key, required this.groups});

  @override
  State<CreateListDialogWidget> createState() => _CreateListDialogWidgetState();
}

class _CreateListDialogWidgetState extends State<CreateListDialogWidget> {
  late final _groups = widget.groups;

  final TextEditingController listNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.green;
    final subtleAccent = accentColor.withAlpha(26);
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text("Create Grocery List"),

      content: Text(
        "Create New Grocery List",
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
          child: Text("Cancel"),
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
          child: Text("Create"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }
}
