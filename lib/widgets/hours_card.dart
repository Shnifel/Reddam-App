import 'package:cce_project/styles.dart';
import 'package:flutter/material.dart';

class HoursCard extends StatefulWidget {
  static const int APPROVED = 0;
  static const int REJECTED = 1;
  static const int PENDING = 2;

  final String header;
  final String summary;
  final String date;
  int status;
  final Widget body;
  final Color fill;

  HoursCard(
      {required this.header, // Header string
      required this.summary, // Summary line
      required this.body, // Widget for expanded body
      required this.date, // Date of notification
      this.status = PENDING, // If hours notification the status
      this.fill = Colors.white,
      super.key});

  @override
  State<HoursCard> createState() => _HoursCardState();
}

class _HoursCardState extends State<HoursCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.fill,
          border: const Border(
              bottom: BorderSide(
            color: Colors.black,
          ))),
      child: ExpansionTile(
        iconColor: secondaryColour,
        textColor: primaryColour,
        collapsedIconColor: secondaryColour,

        title: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Column(children: [
                    // Main notification row
                    Row(children: <Widget>[
                      // Header and summary line
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.header,
                            style: TextStyle(
                                fontSize: 14,
                                color: primaryColour,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.summary,
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),

                      // Date and approval status
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(widget.date,
                              style: const TextStyle(fontSize: 12)),
                          widget.status == HoursCard.APPROVED
                              ? const Text("Approved",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12))
                              : (widget.status == HoursCard.PENDING
                                  ? const Text("Pending",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 255, 197, 76),
                                          fontSize: 12))
                                  : const Text("Rejected",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12)))
                        ],
                      )),
                    ]),
                  ]))
                ])),

        // Body passed
        children: [widget.body],
      ),
    );
  }
}
