import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mymenu/classes/extra/create_event_extra.dart';
import 'package:mymenu/classes/modals/group.dart';
import 'package:mymenu/classes/modals/schedule.dart';
import 'package:mymenu/screens/navigational_base_screen/views/calendar/classes/event_data_source.dart';
import 'package:mymenu/screens/navigational_base_screen/views/calendar/widgets/view_event_dialog_widget.dart';
import 'package:mymenu/services/supabase_helper.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  late Future<List<Schedule>?> _scheduledEvents;
  final CalendarView _selectedView =
      CalendarView.schedule; // Default to the first view (day view)

  late final Future<List<Group>?> _groups;

  @override
  void initState() {
    super.initState();
    _groups = _getGroups();
    _scheduledEvents = _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder(
              future: Future.wait([_scheduledEvents, _groups]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final events = snapshot.data![0] as List<Schedule>? ?? [];
                  final groups = snapshot.data![1] as List<Group>? ?? [];

                  return SfCalendar(
                    view: _selectedView,
                    onTap: (calendarTapDetails) async {
                      if (calendarTapDetails.targetElement.name !=
                          "appointment") {
                        if (groups.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You must be in a group to create an event.',
                              ),
                            ),
                          );
                          return;
                        }

                        final response = await context.push(
                          "/base/create-event",
                          extra: CreateEventExtra(event: null, groups: groups),
                        );

                        if (response != null && response is bool && response) {
                          setState(() {
                            _scheduledEvents = _getEvents();
                          });
                        }

                        return;
                      }

                      final Schedule event =
                          calendarTapDetails.appointments?.first;

                      final response = await showDialog(
                        context: context,
                        builder:
                            (context) => ViewEventDialogWidget(event: event),
                      );

                      if (response != null && response is bool && response) {
                        setState(() {
                          _scheduledEvents = _getEvents();
                        });
                      }
                    },
                    headerHeight: 0, // Remove Header
                    scheduleViewSettings: ScheduleViewSettings(
                      monthHeaderSettings: MonthHeaderSettings(
                        backgroundColor: Colors.green,
                        height: 80.h,
                      ),
                    ),
                    dataSource: EventDataSource(events),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Schedule>?> _getEvents() async {
    return await SupabaseHelper.schedule.getAllScheduledEventsForUser();
  }

  Future<List<Group>?> _getGroups() async {
    return await SupabaseHelper.groups.getGroupsForUser();
  }
}
