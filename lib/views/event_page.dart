import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/services/firestore.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
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
    FirestoreService.getEvents().then((value) => setState(() {
          events = value;
          print(events);
        }));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  void _onDaySelected(DateTime day, DateTime FocusedDay) {
    setState(() {
      today = day;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events.where((element) {
      DateTime current = element["date"].toDate();
      return current.year == day.year &&
          current.month == day.month &&
          current.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Center(
            child: ListView(children: <Widget>[
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
          if (_getEventsForDay(today) != null)
            Column(
              children: _getEventsForDay(today)
                  .map((event) => ListTile(
                      title: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          event["description"],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "${(event["date"] as Timestamp).toDate().hour}:${(event["date"] as Timestamp).toDate().minute}",
                          style: TextStyle(fontSize: 20),
                        ),
                      )))
                  .toList(),
            ),
        ])));
  }
}
