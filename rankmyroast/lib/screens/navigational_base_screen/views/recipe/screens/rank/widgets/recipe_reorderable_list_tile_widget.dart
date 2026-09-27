import 'package:flutter/material.dart';
import 'package:rankmyroast/classes/modals/recipe.dart';
import 'package:rankmyroast/screens/navigational_base_screen/views/recipe/screens/rank/widgets/widgets/recipe_list_tile_widget.dart';

class RecipeReorderableListTileWidget extends StatelessWidget {
  final Recipe recipe;
  final String ranking;
  final int index;
  final void Function(Recipe recipe) removeValueFromList;

  const RecipeReorderableListTileWidget({
    super.key,
    required this.recipe,
    required this.ranking,
    required this.index,
    required this.removeValueFromList,
  });

  @override
  Widget build(BuildContext context) {
    return RecipeListTileWidget(
      recipe: recipe,
      userRanking: ranking,
      groupRanking: ranking,
      isEdit: true,
      dragIndex: index,
      removeValueFromList: removeValueFromList,
    );
  }
}

