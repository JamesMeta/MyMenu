import 'package:mymenu/classes/modals/group.dart';
import 'package:mymenu/classes/modals/recipe.dart';

class CreateRecipeExtra {
  Group? selectedGroup;
  List<Group> groups;
  Recipe? recipeToEdit;
  bool? isCopying;

  CreateRecipeExtra({
    this.selectedGroup,
    this.recipeToEdit,
    required this.groups,
    this.isCopying,
  });
}
