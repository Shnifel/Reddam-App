import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventDisplay extends StatefulWidget {
  final String description, time, eventId;
  final bool showDelete;

  final Function onDelete;

  const EventDisplay(this.eventId, this.description, this.time, this.onDelete,
      {this.showDelete = true, super.key});

  @override
  State<EventDisplay> createState() => _EventDisplayState();
}

class _EventDisplayState extends State<EventDisplay> {
  bool _isLoading = false;

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
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Text(
            widget.time,
            style: const TextStyle(color: primaryColour, fontSize: 15),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                widget.description,
                style: const TextStyle(color: secondaryColour, fontSize: 15),
              )),
          if (widget.showDelete)
            Expanded(
                child: IconButton(
                    alignment: Alignment.centerRight,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await TeacherFirestoreService()
                          .deleteEvent(widget.eventId)
                          .then((value) => widget.onDelete());
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.grey,
                    )))
        ]),
      );
    }
  }
}
