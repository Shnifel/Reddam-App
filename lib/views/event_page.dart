

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
  TextEditingController numweeks= TextEditingController();
  bool recurring=false;
  List<Map<String, dynamic>> events = [];


  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();


  @override
  void initState() {
    super.initState();
    FirestoreService.getEvents().then((value) => setState((){events=value;
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
      DateTime current=element["date"].toDate();
      return current.year==day.year && current.month==day.month && current.day==day.day;

    }).toList();

  }

  @override
  Widget build(BuildContext context) {
    return Padding(

        padding: const EdgeInsets.only(top: 10.0),
        child:
        Center(
            child: ListView(children: <Widget>[
              TextButton.icon(onPressed: (){setState(() {
                ispressed=true;
              });
              }, icon: Icon(Icons.add, color: secondaryColour,) ,label: Text("Add event to calendar",style: TextStyle(color: secondaryColour, fontSize: 25)), style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color?>(Colors.white)),),
              if(ispressed)
                Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(10),
                      child:
                      Material(
                        color: Colors.transparent,
                        child: TextFormField(
                          controller: description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 21,
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              labelText: "Event Description:",
                              labelStyle: loginPageText.copyWith(fontSize: 30)),
                        ),
                      ),),
                    Padding(padding: const EdgeInsets.all(10),
                      child:
                      Row( children:[
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Select Date', style: TextStyle(fontSize: 20),),
                        ),
                        SizedBox(
                          width:20,
                        ),
                        Text(
                          "${selectedDate.toLocal()}".split(' ')[0],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:primaryColour),
                        ),

                      ]
                      ),),

                    Padding(padding: const EdgeInsets.all(10),
                      child:
                      Row( children: [
                        TextButton(
                          onPressed: () => _selectTime(context),
                          child: Text('Select Time', style: TextStyle(fontSize:  20),),
                        ),

                        SizedBox(
                          width: 20.0,
                        ),

                        Text(
                          "${selectedTime.hour}:${selectedTime.minute}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColour),
                        ),
                      ],
                      ),),

                    Padding(padding: const EdgeInsets.all(10),
                        child: Column( children:[
                          Align( alignment: Alignment.centerLeft, child:
                          Text(
                            "Check if event should recur",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColour),
                            textAlign: TextAlign.left,
                          )),
                          SizedBox(
                            height:10 ,
                          ),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: recurring,
                                onChanged: (value) {
                                  setState(() {
                                    recurring = value!;
                                  });
                                },
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: recurring
                                    ? SizedBox(
                                  width: 140,
                                  child: TextField(
                                    controller: numweeks,
                                    keyboardType:TextInputType.number ,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Number of weeks recurring',
                                    ),
                                  ),
                                )
                                    : Container(),
                              ),
                            ],
                          ),
                          ElevatedButton(onPressed: () async {
                            int frequency=1;
                            if (recurring)
                              frequency=int.parse(numweeks.text);
                            DateTime newDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            await FirestoreService.addEvent(description.text, Timestamp.fromDate(newDateTime), recurring, frequency);

                          }, child: Text("Publish new event"))


                        ])),

                  ],),

              TextButton.icon(onPressed: () async{
                await FirestoreService.deleteEvent(Timestamp.fromDate(today));
              }, icon: Icon(Icons.add, color: secondaryColour,) ,label: Text("Remove event from calender",style: TextStyle(color: secondaryColour, fontSize: 25)), style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color?>(Colors.white)),),



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

                  children:



                  _getEventsForDay(today)
                      .map((event) => ListTile(

                    title: Padding( padding: EdgeInsets.all(10.0),
                    child:

                    Text(event["description"], style: TextStyle(fontSize: 20),),),
                    subtitle: Padding( padding: EdgeInsets.all(10.0),
                    child:
                    Text("${(event["date"] as Timestamp).toDate().hour}:${(event["date"] as Timestamp).toDate().minute}", style: TextStyle(fontSize: 20),),
                  )))
                      .toList(),
                ),


            ]

            )
        )
    
    );
  }
}
