import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rankmyroast/classes/modals/group_member.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/groups/screens/widgets/classes/security_level_to_role.dart';
import 'package:rankmyroast/services/supabase_helper.dart';

class GroupMemberListTile extends StatefulWidget {
  final GroupMember groupMember;
  final void Function(GroupMember groupMember) deleteTileCallBack;
  final void Function(GroupMember groupMember, int newSecurityLevel)
  modifySecurityLevelCallBack;

  const GroupMemberListTile({
    super.key,
    required this.groupMember,
    required this.deleteTileCallBack,
    required this.modifySecurityLevelCallBack,
  });

  @override
  State<GroupMemberListTile> createState() => _GroupMemberListTileState();
}

class _GroupMemberListTileState extends State<GroupMemberListTile> {
  Map<int, SecurityLevelToRole> securityLevelToRole = {
    1: SecurityLevelToRole(text: "Customer", icon: Icons.person_4),
    2: SecurityLevelToRole(text: "Employee", icon: Icons.groups_2),
    3: SecurityLevelToRole(text: "Manager", icon: Icons.work),
  };

  late Future<bool> isValid;

  @override
  void initState() {
    super.initState();
    isValid = _isUsernameReal();
  }

  @override
  void didUpdateWidget(covariant GroupMemberListTile oldWidget) {
    if (oldWidget.groupMember.permissionLevel !=
        widget.groupMember.permissionLevel) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: FutureBuilder(
              future: isValid,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(padding: EdgeInsets.all(8));
                } else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.error != null) {
                  return Icon(Icons.dangerous_outlined, size: 25.w);
                } else {
                  if (snapshot.data == true) {
                    return Icon(
                      Icons.check_box,
                      color: Colors.green,
                      size: 25.w,
                    );
                  } else {
                    return Icon(
                      Icons.dangerous_outlined,
                      color: Colors.red,
                      size: 25.w,
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.groupMember.username,
                style: TextStyle(
                  fontSize: 15.sp,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: DropdownMenu(
              // 1. Hide the text by making it transparent so only the leadingIcon shows
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.transparent, // Hides the selected label text
                overflow: TextOverflow.ellipsis,
              ),
              // 2. Add a leadingIcon to the main field based on the selection
              leadingIcon: Icon(
                securityLevelToRole[widget.groupMember.permissionLevel]?.icon ??
                    Icons.help,
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Color.fromARGB(255, 219, 219, 219),
                filled: true,
                constraints: BoxConstraints(minHeight: 40.h, maxHeight: 40.h),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 0, 0, 0),
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.zero, // Helps center the icon
              ),
              menuStyle: MenuStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
              dropdownMenuEntries:
                  securityLevelToRole.entries.map((entry) {
                    return DropdownMenuEntry(
                      value: entry.key,
                      label:
                          entry
                              .value
                              .text, // This is what shows in the open menu
                      leadingIcon: Icon(
                        entry.value.icon,
                      ), // Icon in the open menu
                    );
                  }).toList(),
              initialSelection: widget.groupMember.permissionLevel,
              onSelected: (value) {
                widget.modifySecurityLevelCallBack(
                  widget.groupMember,
                  value ?? 1,
                );
              },
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            flex: 3,
            child: IconButton(
              onPressed: () => widget.deleteTileCallBack(widget.groupMember),
              icon: Icon(Icons.delete, size: 25.w),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _isUsernameReal() async {
    return !await SupabaseHelper.users.checkUsernameUniqueness(
      widget.groupMember.username,
    );
  }
}
