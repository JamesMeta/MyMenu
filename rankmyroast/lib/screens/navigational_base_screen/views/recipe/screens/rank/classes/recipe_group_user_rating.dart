import 'package:rankmyroast/classes/modals/recipe.dart';

class RecipeGroupUserRating {
  final double userRating;
  final double groupRating;
  final Recipe recipe;

  RecipeGroupUserRating({
    required this.userRating,
    required this.groupRating,
    required this.recipe,
  });
}
