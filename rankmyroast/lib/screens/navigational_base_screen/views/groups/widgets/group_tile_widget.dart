import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mymenu/classes/extra/rank_recipe_extra.dart';
import 'package:mymenu/classes/modals/group.dart';

class GroupTileWidget extends StatelessWidget {
  final Group group;
  final int index;
  final VoidCallback? editGroupCallback;

  const GroupTileWidget({
    super.key,
    required this.group,
    required this.index,
    this.editGroupCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                // Group Icon Avatar
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade100, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      group.isPersonalGroup
                          ? Icons.person_rounded
                          : Icons.group_rounded,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              group.name,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            "${group.groupMembers.length}",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Text(
                              "•",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 13.sp,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              "${group.recipes.length} recipe${group.recipes.length == 1 ? '' : 's'}",
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 6.w),

                // Trailing Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.push(
                          "/base/rank-recipe",
                          extra: RankRecipeExtra(
                            ratings: null,
                            recipeToRank: null,
                            group: group,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.rate_review_outlined,
                        color: Colors.green.shade700,
                        size: 18.sp,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.w,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      tooltip: "Rank recipes",
                    ),
                    SizedBox(width: 5.w),
                    IconButton(
                      onPressed: () async {
                        final refresh = await context.push(
                          '/base/create-group',
                          extra: group,
                        );
                        if (refresh == true && editGroupCallback != null) {
                          editGroupCallback!();
                        }
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.grey.shade700,
                        size: 18.sp,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.w,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      tooltip: "Edit group",
                    ),
                    SizedBox(width: 2.w),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 6.h,
                        ),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: Colors.grey.shade400,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
