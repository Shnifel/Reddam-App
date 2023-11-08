import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherTimetable/add_event.dart';
import 'package:cce_project/widgets/event_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime today = DateTime.now();
  List<Map<String, dynamic>> events = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    FirestoreService.getEvents().then((value) => setState(() {
          events = value;
        }));
  }

  void _onDaySelected(DateTime day, DateTime FocusedDay) {
    setState(() {
      today = day;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events.where((element) {
      DateTime current = element["date"].toDate();
      bool recurring = element["recurring"];
      return (!recurring &&
              current.year == day.year &&
              current.month == day.month &&
              current.day == day.day) ||
          (recurring && day.weekday == element["day"]);
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
            Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text('Events',
                    style: loginPageText.copyWith(
                        fontSize: 35, fontWeight: FontWeight.bold))),
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
                          event["description"],
                          DateFormat('HH:mm')
                              .format((event["date"] as Timestamp).toDate()),
                          () {},
                          showDelete: false,
                        ))
                    .toList(),
              ),
          ]))),
    );
  }
}
