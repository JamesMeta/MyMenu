import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mymenu/classes/modals/group.dart';

class AddToGroupsDialogWidget extends StatefulWidget {
  final List<Group> groups;
  final List<Group>? selectedGroups;

  const AddToGroupsDialogWidget({
    super.key,
    required this.groups,
    this.selectedGroups,
  });

  @override
  State<AddToGroupsDialogWidget> createState() =>
      _AddToGroupsDialogWidgetState();
}

class _AddToGroupsDialogWidgetState extends State<AddToGroupsDialogWidget> {
  final List<Group> _selectedGroups = [];

  @override
  void initState() {
    if (widget.selectedGroups != null) {
      _selectedGroups.addAll(
        widget.groups.where(
          (group) => widget.selectedGroups!.any((s) => s.id == group.id),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Defining a local green theme for consistency
    final Color primaryGreen = Colors.green;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: const Text(
          "Select Groups",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.groups.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final group = widget.groups[index];
                  final isSelected = _selectedGroups.contains(group);

                  return CheckboxListTile(
                    activeColor: primaryGreen,
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGroups.add(group);
                        } else {
                          _selectedGroups.remove(group);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () => context.pop(_selectedGroups),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("Apply"),
          ),
        ),
      ],
    );
  }
}
