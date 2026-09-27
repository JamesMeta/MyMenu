import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rankmyroast/classes/modals/recipe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectRecipeTileWidget extends StatelessWidget {
  const SelectRecipeTileWidget({
    super.key,
    required this.recipe,
    this.onTap,
  });

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? recipeImageUrl = recipe.publicImageUrl;
    final int totalMinutes = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);

    return Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Food Image or Fallback
                      recipeImageUrl != null
                          ? CachedNetworkImage(
                            httpHeaders: {
                              'Authorization':
                                  'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
                            },
                            imageUrl: recipeImageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.green,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey.shade100,
                                  child: Center(
                                    child: Icon(
                                      Icons.restaurant_rounded,
                                      color: Colors.grey.shade400,
                                      size: 28.sp,
                                    ),
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.green.shade50,
                            child: Center(
                              child: Image.asset(
                                "assets/images/rankmyroast_icon4.png",
                                width: 52.w,
                                height: 52.w,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: Colors.green.shade700,
                                      size: 32.sp,
                                    ),
                              ),
                            ),
                          ),

                      // Floating Cooking Time Badge
                      if (totalMinutes > 0)
                        Positioned(
                          bottom: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: Colors.white,
                                  size: 11.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  "$totalMinutes min",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Public Indicator Badge
                      if (recipe.isPublic)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.public_rounded,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Card Footer with Title and Details
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.grey.shade900,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_dining_outlined,
                            size: 12.sp,
                            color: Colors.green.shade700,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              recipe.ingredientList.isNotEmpty
                                  ? "${recipe.ingredientList.length} ingredient${recipe.ingredientList.length == 1 ? '' : 's'}"
                                  : "View details",
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

