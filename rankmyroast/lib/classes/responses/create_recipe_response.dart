import 'package:mymenu/classes/responses/async_response.dart';
import 'package:mymenu/classes/modals/group.dart';

class CreateRecipeResponse extends AsyncResponse {
  final List<Group>? failedToAddGroups;
  final bool? failedToUploadImage;

  CreateRecipeResponse({
    required super.success,
    super.localError,
    super.errorMessage,
    this.failedToAddGroups,
    this.failedToUploadImage,
  });
}
