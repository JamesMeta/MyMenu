import 'package:flutter/material.dart';

class GroupSecurityInformationalDialog extends StatelessWidget {
  const GroupSecurityInformationalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Colors.green;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: const Text(
          "Group Security Levels",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4),
            _SecurityLevelRow(
              icon: Icons.person_4,
              title: "Customer",
              description:
                  "Can view your recipes and group calendar events, and give rankings/ratings. Cannot add recipes, events, lists or list items, or adjust group settings.",
            ),
            Divider(height: 24),
            _SecurityLevelRow(
              icon: Icons.groups_2,
              title: "Employee",
              description:
                  "Can interact with group-linked lists and create recipes and calendar events. Cannot modify content they did not create or change group settings.",
            ),
            Divider(height: 24),
            _SecurityLevelRow(
              icon: Icons.work,
              title: "Manager",
              description:
                  "Can view and manage group data, settings and members, and create group-linked lists.",
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("Got it!"),
          ),
        ),
      ],
    );
  }
}

class _SecurityLevelRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityLevelRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}
