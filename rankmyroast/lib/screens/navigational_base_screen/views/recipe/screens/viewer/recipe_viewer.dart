import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rankmyroast/classes/extra/create_recipe_extra.dart';
import 'package:rankmyroast/classes/extra/rank_recipe_extra.dart';
import 'package:rankmyroast/classes/mixin/snackbar_service.dart';
import 'package:rankmyroast/classes/modals/group.dart';
import 'package:rankmyroast/classes/modals/recipe.dart';
import 'package:rankmyroast/classes/modals/recipe_rating.dart';
import 'package:rankmyroast/common_widgets/confirmation_dialog_widget.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/recipe/screens/viewer/widgets/rating_dialog_widget.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/recipe/screens/viewer/widgets/recipe_list_widget.dart';
import 'package:rankmyroast/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeViewer extends StatefulWidget {
  final Recipe? recipe;
  final Group? group;
  final List<Group>? userGroups;

  const RecipeViewer({super.key, this.recipe, this.group, this.userGroups});

  @override
  State<RecipeViewer> createState() => _RecipeViewerState();
}

class _RecipeViewerState extends State<RecipeViewer> with SnackbarService {
  late final bool _isOwner;
  late final bool _isGroupAdmin;
  late final bool _hasUserRated;
  late final RecipeRating? _userRating;
  late final Recipe _recipe;
  late final Group? _group;
  late final List<Group>? _userGroups;
  late final String? _recipeImageUrl;

  late final Future<List<RecipeRating>?> _ratings;

  final TextEditingController _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe!;
    _recipeImageUrl = _recipe.publicImageUrl;
    _group = widget.group;
    _userGroups = widget.userGroups;

    _isOwner = _recipe.userId == Supabase.instance.client.auth.currentUser!.id;

    _ratings = _fetchRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          _isOwner && _userGroups != null
              ? IconButton(
                onPressed: () {
                  context.pushReplacement(
                    "/base/create-recipe",
                    extra: CreateRecipeExtra(
                      recipeToEdit: _recipe,
                      selectedGroup: _group,
                      groups: _userGroups,
                    ),
                  );
                },
                icon: Icon(Icons.edit),
              )
              : SizedBox(),
          IconButton(
            onPressed: () {
              context.pushReplacement(
                "/base/create-recipe",
                extra: CreateRecipeExtra(
                  recipeToEdit: _recipe,
                  selectedGroup: _group,
                  groups: _userGroups ?? [],
                  isCopying: true,
                ),
              );
            },
            icon: Icon(Icons.copy),
          ),
          FutureBuilder(
            future: SupabaseHelper.groups.isUserGroupAdmin(_group!.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return IconButton(
                    onPressed: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => ConfirmationDialogWidget(
                              title: "Remove Recipe From Group?",
                              content:
                                  "Removing this recipe permanently revokes group access and deletes its group rankings and ratings. The recipe itself will not be deleted and remains accessible to the owner and other groups.",
                              confirmButtonText: "Remove",
                              cancelButtonText: "Cancel",
                              isDestructiveAction: true,
                            ),
                      );

                      if (confirmDelete == true) {
                        final deleteResponse = await SupabaseHelper.recipe
                            .removeRecipeFromGroup(_recipe.id, _group.id);
                        if (deleteResponse == true) {
                          if (context.mounted) {
                            showSnackbar(context, "Recipe removed from group");
                            context.pop();
                          }
                        } else {
                          if (context.mounted) {
                            showErrorSnackbar(
                              context,
                              "Error removing recipe from group",
                            );
                          }
                        }
                      }
                    },
                    icon: Icon(Icons.delete),
                  );
                } else {
                  return SizedBox();
                }
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(115, 0, 0, 0),
                  blurRadius: 10,
                  offset: Offset(2, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child:
                        _recipeImageUrl != null
                            ? Container(
                              constraints: BoxConstraints(
                                maxHeight: 300.h,
                                maxWidth: double.infinity,
                              ),

                              child: CachedNetworkImage(
                                httpHeaders: {
                                  'Authorization':
                                      'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
                                },
                                imageUrl: _recipeImageUrl,
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 250.h,

                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            )
                            : Container(
                              constraints: BoxConstraints(
                                maxHeight: 250.h,
                                maxWidth: double.infinity,
                              ),
                              child: Image.asset(
                                "assets/images/rankmyroast_icon4.png",
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 250.h,
                              ),
                            ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _recipe.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: _ratings,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                final ratings = snapshot.data;
                                if (ratings == null || ratings.isEmpty) {
                                  if (_group != null) {
                                    if (_group.useRating) {
                                      return TextButton(
                                        onPressed:
                                            () async => _showRatingDialog(),
                                        child: Text(
                                          "Be the first to leave a rating",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return TextButton(
                                        onPressed:
                                            () async => _goToRanking(ratings),
                                        child: Text(
                                          "Be the first to leave a ranking",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    return Text("Error: Group not found");
                                  }
                                } else {
                                  if (_group != null) {
                                    if (_group.useRating &&
                                        ratings.isNotEmpty) {
                                      // 1. Filter for specific recipe and non-null ratings once
                                      final recipeRatings = ratings.where(
                                        (r) =>
                                            r.recipeId == _recipe.id &&
                                            r.rating != null,
                                      );

                                      // 2. Calculate average safely
                                      final averageRating =
                                          recipeRatings.isEmpty
                                              ? 0.0
                                              : recipeRatings.fold<double>(
                                                    0,
                                                    (sum, r) => sum + r.rating!,
                                                  ) /
                                                  recipeRatings.length;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${averageRating.toStringAsFixed(1)} / 10 (${recipeRatings.length} ratings)",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      final averages = <String, double>{};
                                      final counts = <String, int>{};

                                      for (var r in ratings) {
                                        final val =
                                            r.ranking?.toDouble() ?? 0.0;
                                        averages.update(
                                          r.recipeId,
                                          (curr) => curr + val,
                                          ifAbsent: () => val,
                                        );
                                        counts.update(
                                          r.recipeId,
                                          (curr) => curr + 1,
                                          ifAbsent: () => 1,
                                        );
                                      }

                                      // 2. Map to averages and sort descending (highest score = Rank #1)
                                      final sortedIds =
                                          averages.keys.toList()..sort((a, b) {
                                            final avgA =
                                                averages[a]! / counts[a]!;
                                            final avgB =
                                                averages[b]! / counts[b]!;
                                            return avgA.compareTo(avgB);
                                          });

                                      // 3. Find rank (1-indexed)
                                      final rank =
                                          sortedIds.indexOf(_recipe.id) + 1;

                                      String rankText;
                                      Color rankColor;
                                      if (rank == 0) {
                                        rankText = "Unranked";
                                        rankColor = Colors.grey[600]!;
                                      } else if (rank == 1) {
                                        rankText = "Top Ranked Recipe!";
                                        rankColor = Colors.green;
                                      } else {
                                        rankText =
                                            "Standing: #$rank of ${sortedIds.length} Recipes";
                                        rankColor = Colors.grey[600]!;
                                      }

                                      return Text(
                                        rankText,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: rankColor,
                                        ),
                                      );
                                    }
                                  } else {
                                    return Text("Error: Group not found");
                                  }
                                }
                              } else {
                                return Text("Error fetching ratings");
                              }
                            },
                          ),

                          FutureBuilder(
                            future: _ratings,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              } else if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                final ratings = snapshot.data;
                                if (ratings == null || ratings.isEmpty) {
                                  return SizedBox();
                                } else {
                                  if (_group != null) {
                                    if (_group.useRating) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_document,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 4),
                                          _hasUserRated
                                              ? TextButton(
                                                onPressed:
                                                    () async =>
                                                        _showRatingDialog(),
                                                child: Text(
                                                  "Tap to update your rating",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                              : TextButton(
                                                onPressed:
                                                    () async =>
                                                        _showRatingDialog(),
                                                child: Text(
                                                  "Tap to leave a rating",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_document,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 4),
                                          _hasUserRated
                                              ? TextButton(
                                                onPressed:
                                                    () async =>
                                                        _goToRanking(ratings),
                                                child: Text(
                                                  "Tap to update your ranking",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                              : TextButton(
                                                onPressed:
                                                    () async =>
                                                        _goToRanking(ratings),
                                                child: Text(
                                                  "Tap to leave a ranking",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                        ],
                                      );
                                    }
                                  } else {
                                    return Text("No Group Found For Recipe");
                                  }
                                }
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Prep",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _recipe.prepTime != null
                                            ? "${_recipe.prepTime} mins"
                                            : "???",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(width: 100.w),

                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cook",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _recipe.cookTime != null
                                            ? "${_recipe.cookTime} mins"
                                            : "???",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Divider(color: Colors.grey[600]),

                      SizedBox(height: 12),
                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      RecipeListWidget(
                        itemList: _recipe.ingredientList,
                        numbered: false,
                      ),
                      SizedBox(height: 12),

                      Divider(color: Colors.grey[600]),

                      SizedBox(height: 12),
                      Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      RecipeListWidget(
                        itemList: _recipe.instructionsList,
                        numbered: true,
                      ),

                      SizedBox(height: 32),
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

  Future<void> _goToRanking(List<RecipeRating>? ratings) async {
    final response = await context.push(
      "/base/rank-recipe",
      extra: RankRecipeExtra(
        ratings: ratings,
        recipeToRank: _recipe,
        group: _group,
      ),
    );

    if (response == true && mounted) {
      context.pop();
    }
  }

  Future<void> _showRatingDialog() async {
    showDialog(
      context: context,
      builder:
          (context) => RatingDialogWidget(
            recipe: _recipe,
            group: _group,
            pastRating: _userRating?.rating?.toInt(),
          ),
    );
  }

  Future<List<RecipeRating>?> _fetchRatings() async {
    final groupId = widget.group?.id;
    final recipeId = widget.recipe?.id;

    if (groupId == null || recipeId == null) {
      return null;
    }

    final response = await SupabaseHelper.recipe.getRatingsByGroupId(groupId);
    _hasUserRated = response != null ? _checkIfUserHasRated(response) : false;

    if (_hasUserRated) {
      _userRating = response!.firstWhere(
        (r) =>
            r.userId == Supabase.instance.client.auth.currentUser?.id &&
            r.recipeId == widget.recipe?.id,
      );
    } else {
      _userRating = null;
    }

    return response;
  }

  bool _checkIfUserHasRated(List<RecipeRating> ratings) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    final groupUsesRatings = _group?.useRating ?? false;

    if (groupUsesRatings) {
      return ratings.any(
        (r) =>
            r.userId == userId &&
            r.recipeId == widget.recipe?.id &&
            r.rating != null,
      );
    } else {
      return ratings.any(
        (r) =>
            r.userId == userId &&
            r.recipeId == widget.recipe?.id &&
            r.ranking != null,
      );
    }
  }

  @override
  void dispose() {
    _ratingController.dispose();
    super.dispose();
  }
}
