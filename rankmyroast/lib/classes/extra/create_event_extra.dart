import 'package:rankmyroast/classes/modals/group.dart';
import 'package:rankmyroast/classes/modals/schedule.dart';

class CreateEventExtra {
  final Schedule? event;
  final List<Group>? groups;

  CreateEventExtra({required this.event, this.groups});
}
