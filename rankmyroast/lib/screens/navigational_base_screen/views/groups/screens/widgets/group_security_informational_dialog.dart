import 'package:flutter/material.dart';

class GroupSecurityInformationalDialog extends StatelessWidget {
  const GroupSecurityInformationalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Group Security Levels"),
      actionsAlignment: MainAxisAlignment.center,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.person),
              Expanded(
                child: Text(
                  "Customer: Can view your recipes, group calendar events, and give rankings/ratings but can not add their own recipes, events, lists/list items or adjust the group settings.",
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group),
              Expanded(
                child: Text(
                  "Employee: Can interact with group linked lists and create their own group recipes and calendar events, but cannot modify existing ones they didn't author or change group settings.",
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cases),
              Expanded(
                child: Text(
                  "Manager: Full access to view, modify, and manage group data, settings and members as well as create group linked lists.",
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Got it!"),
        ),
      ],
    );
  }
}
