import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/classes/modals/group.dart';
import 'package:rankmyroast/services/supabase_helper.dart';

class CreateListDialogWidget extends StatefulWidget {
  final List<Group> groups;

  const CreateListDialogWidget({super.key, required this.groups});

  @override
  State<CreateListDialogWidget> createState() => _CreateListDialogWidgetState();
}

class _CreateListDialogWidgetState extends State<CreateListDialogWidget>
    with SnackbarService {
  late final _groups = widget.groups;

  Group? _selectedGroup;

  bool _isLoading = false;

  final TextEditingController listNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.green.shade700;
    final subtleAccent = accentColor.withAlpha(26);
    final hasListName = listNameController.text.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      contentPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Container(
        width: 360.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: Text(
                  "Create a New Grocery List",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Give it a name",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: listNameController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'e.g. Weekly Market Run',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Text(
                        "Link to a group",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Tooltip(
                        message:
                            "Optionally linking this grocery list to a group allows all members of that group to view and edit the list.",
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 18.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  DropdownButtonFormField<String>(
                    value: _selectedGroup?.id,
                    isExpanded: true,
                    hint: Text(
                      'Select a group',
                      style: TextStyle(fontSize: 15.sp, color: Colors.black54),
                    ),
                    icon: Icon(Icons.expand_more_rounded, color: accentColor),
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentColor, width: 1.5),
                      ),
                    ),
                    items:
                        _groups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group.id,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? selectedGroupId) {
                      setState(() {
                        _selectedGroup = _groups.firstWhere(
                          (group) => group.id == selectedGroupId,
                          orElse: () => _groups.first,
                        );
                      });
                    },
                  ),
                  if (_selectedGroup != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: subtleAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 16.sp,
                            color: accentColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Linked to ${_selectedGroup!.name}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed:
              hasListName
                  ? () {
                    if (_isLoading) return; // Prevent multiple submissions

                    setState(() {
                      _isLoading = true;
                    });

                    createNewList().then((success) {
                      if (!context.mounted) {
                        return;
                      }

                      if (success == true) {
                        Navigator.of(context).pop(true);
                      } else {
                        showSnackbar(
                          context,
                          "Failed to create the grocery list. Please try again.",
                        );
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    });
                  }
                  : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child:
              _isLoading
                  ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                  : Text("Create"),
        ),
      ],
    );
  }

  Future<bool?> createNewList() async {
    if (listNameController.text.trim().isEmpty) {
      return false;
    }

    final response = await SupabaseHelper.grocery.createGroceryList(
      listNameController.text.trim(),
      _selectedGroup?.id,
    );

    if (response == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }
}
