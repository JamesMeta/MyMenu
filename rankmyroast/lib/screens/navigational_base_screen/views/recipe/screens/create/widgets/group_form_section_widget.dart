import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mymenu/classes/modals/group.dart';
import 'package:mymenu/screens/navigational_base_screen/views/recipe/screens/create/widgets/widgets/add_to_groups_dialog_widget.dart';
import 'package:mymenu/screens/navigational_base_screen/views/recipe/screens/create/widgets/widgets/item_list_view_widget.dart';

class GroupFormSectionWidget extends StatefulWidget {
  final String header;
  final String subtitle;
  final String includeSectionText;
  final bool isNumericalList;
  final bool includeSection;
  final bool isHidden;
  final VoidCallback onModify;
  final VoidCallback onHide;
  final TextEditingController controller;
  final List<Group> itemsList;
  final List<Group> groups;
  final void Function(void Function()) setParentState;
  final void Function(String item) deleteFromParent;

  const GroupFormSectionWidget({
    super.key,
    required this.header,
    required this.subtitle,
    required this.includeSectionText,
    required this.isNumericalList,
    required this.includeSection,
    required this.isHidden,
    required this.onModify,
    required this.onHide,
    required this.deleteFromParent,
    required this.controller,
    required this.itemsList,
    required this.groups,
    required this.setParentState,
  });

  @override
  State<GroupFormSectionWidget> createState() => _GroupFormSectionWidgetState();
}

class _GroupFormSectionWidgetState extends State<GroupFormSectionWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return !widget.isHidden
        ? widget.includeSection
            ? Column(
              children: [
                ExpansionTile(
                  onExpansionChanged:
                      (value) => setState(() => _isExpanded = value),
                  tilePadding: EdgeInsets.symmetric(horizontal: 8.w),
                  backgroundColor: Colors.green,

                  initiallyExpanded: true,
                  shape: RoundedRectangleBorder(
                    side:
                        widget.itemsList.isNotEmpty
                            ? BorderSide(color: Colors.grey[600]!)
                            : BorderSide(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  iconColor: Colors.white,
                  collapsedIconColor: Colors.grey[600],
                  collapsedBackgroundColor: Colors.white,
                  collapsedTextColor: Colors.grey[600],
                  textColor: Colors.white,
                  leading: IconButton(
                    onPressed: widget.onModify,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,

                      backgroundColor:
                          _isExpanded
                              ? const Color.fromARGB(255, 90, 182, 93)
                              : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.close,
                      color: _isExpanded ? Colors.white : Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  title: Text(
                    widget.header,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  children: [
                    ItemListViewWidget(
                      items:
                          widget.itemsList.map((group) => group.name).toList(),
                      isNumericalList: false,
                      deleteForParentList:
                          (String item) => widget.deleteFromParent(item),
                      updatePositionForParentList:
                          (int oldIndex, int newIndex) {},
                      setParentState: widget.setParentState,
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Container(
                  height: 42.h,
                  alignment: Alignment.center,

                  child: Row(
                    children: [
                      Expanded(
                        flex: 17,
                        child: Container(
                          height: 42.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final List<Group>? result = await showDialog(
                                context: context,
                                builder:
                                    (context) => AddToGroupsDialogWidget(
                                      groups: widget.groups,
                                      selectedGroups: widget.itemsList,
                                    ),
                              );

                              if (result != null) {
                                widget.setParentState(() {
                                  widget.itemsList.clear();
                                  widget.itemsList.addAll(result);
                                });
                              }
                            },
                            child: TextField(
                              controller: widget.controller,

                              decoration: InputDecoration(
                                labelText: widget.subtitle,
                                labelStyle: TextStyle(fontSize: 18),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,

                                isCollapsed: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                enabled: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: IconButton(
                          padding: EdgeInsets.zero,

                          onPressed: () {},
                          icon: Icon(Icons.add, color: Colors.white),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 42.h),

                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
            : Center(
              child: Column(
                children: [
                  Text(
                    widget.includeSectionText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 25,
                        onPressed: widget.onHide,
                        icon: Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          minimumSize: Size(40.h, 40.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onModify,
                        iconSize: 25,
                        icon: Icon(Icons.check, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(40.h, 40.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
        : SizedBox();
  }
}
