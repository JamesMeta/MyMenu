import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mymenu/classes/modals/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeListTileWidget extends StatelessWidget {
  final Recipe recipe;
  final String userRanking;
  final String groupRanking;
  final bool isEdit;
  final bool isGroupRatingTile;
  final bool isUsingRatings;
  final int? dragIndex;
  final void Function(Recipe recipe)? removeValueFromList;

  const RecipeListTileWidget({
    super.key,
    required this.recipe,
    required this.userRanking,
    required this.groupRanking,
    this.isEdit = false,
    this.isGroupRatingTile = false,
    this.isUsingRatings = false,
    this.dragIndex,
    this.removeValueFromList,
  });

  @override
  Widget build(BuildContext context) {
    final String? recipeImageUrl = recipe.publicImageUrl;
    final int? userRankingInt = int.tryParse(userRanking);
    final int? groupRankingInt = int.tryParse(groupRanking);
    final int totalMinutes = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);

    int? difference;
    if (userRankingInt != null && groupRankingInt != null) {
      difference = userRankingInt - groupRankingInt;
      if (isUsingRatings) {
        difference = difference * -1;
      }
    }

    final String displayRank = isGroupRatingTile ? groupRanking : userRanking;
    final int? rankNumber = int.tryParse(displayRank);

    final Color badgeBg;
    final Color badgeBorder;
    final Color badgeText;

    if (rankNumber == 1 && !isUsingRatings) {
      badgeBg = const Color(0xFFFFF9E6);
      badgeBorder = const Color(0xFFFFE082);
      badgeText = const Color(0xFFB78103);
    } else if (displayRank == "N/A") {
      badgeBg = Colors.grey.shade100;
      badgeBorder = Colors.grey.shade300;
      badgeText = Colors.grey.shade600;
    } else {
      badgeBg = Colors.green.shade50;
      badgeBorder = Colors.green.shade100;
      badgeText = Colors.green.shade800;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
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
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                // Thumbnail with optional remove button in edit mode
                Stack(
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            recipeImageUrl != null
                                ? CachedNetworkImage(
                                  httpHeaders: {
                                    'Authorization':
                                        'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
                                  },
                                  imageUrl: recipeImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Center(
                                        child: SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.green,
                                                ),
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Icon(
                                        Icons.restaurant_rounded,
                                        color: Colors.grey.shade400,
                                        size: 26.sp,
                                      ),
                                )
                                : Container(
                                  color: Colors.green.shade50,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/images/rankmyroast_icon4.png",
                                      width: 44.w,
                                      height: 44.w,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.restaurant_menu_rounded,
                                            color: Colors.green.shade700,
                                            size: 26.sp,
                                          ),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    if (isEdit && removeValueFromList != null)
                      Positioned(
                        top: 3.w,
                        left: 3.w,
                        child: GestureDetector(
                          onTap: () => removeValueFromList!(recipe),
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),

                // Title and Meta Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (totalMinutes > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              "$totalMinutes min",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (recipe.ingredientList.isNotEmpty) ...[
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
                                Icons.local_dining_outlined,
                                size: 12.sp,
                                color: Colors.green.shade700,
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Text(
                                  "${recipe.ingredientList.length} ingr.",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        )
                      else if (recipe.ingredientList.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.local_dining_outlined,
                              size: 12.sp,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 3.w),
                            Flexible(
                              child: Text(
                                "${recipe.ingredientList.length} ingredients",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          isGroupRatingTile
                              ? (isUsingRatings
                                  ? "Group Rating"
                                  : "Group Ranking")
                              : (isUsingRatings
                                  ? "Your Rating"
                                  : "Your Ranking"),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Stat / Ranking Badge
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isUsingRatings ? "RATING" : "RANK",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isGroupRatingTile ? 8.w : 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: badgeBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (rankNumber == 1 && !isUsingRatings) ...[
                            Icon(
                              Icons.emoji_events_rounded,
                              color: const Color(0xFFE6A700),
                              size: 14.sp,
                            ),
                            SizedBox(width: 3.w),
                          ],
                          Text(
                            displayRank,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                            ),
                          ),
                          if (isGroupRatingTile && difference != null) ...[
                            SizedBox(width: 4.w),
                            if (difference == 0)
                              Icon(
                                CupertinoIcons.equal,
                                color: Colors.grey.shade600,
                                size: 12.sp,
                              )
                            else if (difference > 0)
                              Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.green.shade700,
                                size: 13.sp,
                              )
                            else
                              Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.red.shade700,
                                size: 13.sp,
                              ),
                            Text(
                              difference.abs().toString(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    difference == 0
                                        ? Colors.grey.shade600
                                        : difference > 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Drag Handle (only shown during edit/reorder)
                if (isEdit && dragIndex != null) ...[
                  SizedBox(width: 4.w),
                  ReorderableDragStartListener(
                    index: dragIndex!,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 6.h,
                      ),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: Colors.grey.shade400,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
