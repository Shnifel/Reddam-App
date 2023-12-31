import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherTimetable/add_event.dart';
import 'package:cce_project/widgets/event_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TeacherTimetablePanelPage extends StatefulWidget {
  @override
  _TeacherTimetablePanelPageState createState() =>
      _TeacherTimetablePanelPageState();
}

class _TeacherTimetablePanelPageState extends State<TeacherTimetablePanelPage> {
  DateTime today = DateTime.now();
  bool ispressed = false;
  TextEditingController description = TextEditingController();
  TextEditingController numweeks = TextEditingController();
  bool recurring = false;
  List<Map<String, dynamic>> events = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    TeacherFirestoreService().getEvents().then((value) => setState(() {
          events = value;
        }));
  }

  void _onDaySelected(DateTime day, DateTime FocusedDay) {
    setState(() {
      today = day;
    });
  }

  bool isDateExcluded(List<dynamic> timestampArray, DateTime dateToCheck) {
    // Extract the date components from the DateTime object
    int dayToCheck = dateToCheck.day;
    int monthToCheck = dateToCheck.month;
    int yearToCheck = dateToCheck.year;

    // Iterate through the Timestamp array
    for (Timestamp timestamp in timestampArray) {
      // Convert the Timestamp to a DateTime object
      DateTime timestampDate = timestamp.toDate();

      // Check if the date components match (ignoring time)
      if (timestampDate.day == dayToCheck &&
          timestampDate.month == monthToCheck &&
          timestampDate.year == yearToCheck) {
        // Date matches
        return true;
      }
    }

    return false;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events.where((element) {
      DateTime current = element["date"].toDate();
      bool recurring = element["recurring"];
      return (!recurring &&
              current.year == day.year &&
              current.month == day.month &&
              current.day == day.day) ||
          (recurring &&
              day.weekday == element["day"] &&
              (element["excludes"] == null ||
                  !isDateExcluded(element["excludes"], day)));
    }).toList();
  }

  List<dynamic> _getRecurringEventsForDay(DateTime day) {
    return events.where((element) {
      bool recurring = element["recurring"];
      return (recurring &&
          day.weekday == element["day"] &&
          (element["excludes"] == null ||
              !isDateExcluded(element["excludes"], day)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Center(
              child: ListView(children: <Widget>[
            AddEvent(() async {
              await TeacherFirestoreService()
                  .getEvents()
                  .then((value) => setState(() {
                        events = value;
                      }));
            }),
            TableCalendar(
              rowHeight: 75,
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              focusedDay: today,
              firstDay: DateTime.utc(2023, 09, 20),
              lastDay: DateTime.utc(2070, 12, 31),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
            const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Events for the day",
                  style: TextStyle(color: secondaryColour, fontSize: 20),
                )),
            if (_getEventsForDay(today) != null)
              Column(
                children: _getEventsForDay(today)
                        .map((event) => EventDisplay(
                              event["id"],
                              event["description"] +
                                  (event["recurring"] == true
                                      ? " (Recurring)"
                                      : ""),
                              DateFormat('HH:mm').format(
                                  (event["date"] as Timestamp).toDate()),
                              () async {
                                await TeacherFirestoreService()
                                    .getEvents()
                                    .then((value) => setState(() {
                                          events = value;
                                        }));
                              },
                              key: Key(event["id"]),
                            ))
                        .toList() +
                    _getRecurringEventsForDay(today)
                        .map((event) => EventDisplay(
                              event["id"],
                              event["description"],
                              DateFormat('HH:mm').format(
                                  (event["date"] as Timestamp).toDate()),
                              () async {
                                await TeacherFirestoreService()
                                    .getEvents()
                                    .then((value) => setState(() {
                                          events = value;
                                        }));
                              },
                              deleteDayOnly: true,
                              excludeDate: today,
                              key: Key(event["id"] + "r"),
                            ))
                        .toList(),
              ),
          ]))),
    );
  }
}
