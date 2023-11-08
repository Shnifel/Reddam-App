import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  final Function onFinish;

  const AddEvent(this.onFinish, {super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController numweeks = TextEditingController();
  bool _addEvent = false;
  bool _isLoading = false;
  bool recurring = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  DateTime? _selectedDate = DateTime.now();

  String getDayOfWeek(DateTime dateTime) {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return daysOfWeek[dateTime.weekday - 1];
  }

  Future<void> _selectDay(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    DateTime initialDate = _selectedDate ?? currentDate;

    DateTime firstDayOfWeek =
        initialDate.subtract(Duration(days: initialDate.weekday - 1));

    DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDayOfWeek,
      lastDate: lastDayOfWeek,
      selectableDayPredicate: (DateTime date) {
        return date.weekday >= firstDayOfWeek.weekday &&
            date.weekday <= lastDayOfWeek.weekday;
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColour,
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_addEvent)
            Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _addEvent = false;
                    });
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: secondaryColour,
                  ),
                  label: const Text("Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(Colors.white)),
                ))
          else
            Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _addEvent = true;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: secondaryColour,
                  ),
                  label: const Text("Add event to calendar",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(Colors.white)),
                )),
          if (_addEvent)
            Form(
                child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          iconColor: secondaryColour,
                          hintText: 'Event description...',
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColour))),
                      style: const TextStyle(color: Colors.black),
                    )),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      children: <Widget>[
                        const Text("Weekly recurring event"),
                        Checkbox(
                          activeColor: secondaryColour,
                          value: recurring,
                          onChanged: (value) {
                            setState(() {
                              recurring = value!;
                            });
                          },
                        ),
                      ],
                    )),
                if (recurring)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectDay(context),
                          child: const Text(
                            'Select day of the week',
                            style:
                                TextStyle(fontSize: 15, color: secondaryColour),
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          getDayOfWeek(_selectedDate == null
                              ? DateTime.now()
                              : _selectedDate!),
                          style: const TextStyle(
                              fontSize: 15, color: primaryColour),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(children: [
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text(
                          'Select Date',
                          style:
                              TextStyle(fontSize: 15, color: secondaryColour),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style:
                            const TextStyle(fontSize: 15, color: primaryColour),
                      ),
                    ]),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectTime(context),
                        child: const Text(
                          'Select Time',
                          style:
                              TextStyle(fontSize: 15, color: secondaryColour),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        selectedTime.format(context),
                        style:
                            const TextStyle(fontSize: 15, color: primaryColour),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the radius here
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: primaryColour,
                        width: 0,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      DateTime newDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      await TeacherFirestoreService()
                          .addEvent(
                              _descriptionController.text,
                              Timestamp.fromDate(newDateTime),
                              recurring,
                              recurring && _selectedDate != null
                                  ? _selectedDate!.weekday
                                  : selectedDate.weekday)
                          .then((value) => setState(
                                () {
                                  _isLoading = false;
                                  _addEvent = false;
                                  widget.onFinish();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor:
                                          Color.fromARGB(255, 11, 123, 35),
                                      content: Text(
                                          "Successfully added new event",
                                          textAlign: TextAlign.center),
                                    ),
                                  );
                                },
                              ));
                    },
                    child: const Text(
                      "Publish new event",
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ))
        ],
      );
    }
  }
}
