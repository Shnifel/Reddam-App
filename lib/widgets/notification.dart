import 'package:cce_project/styles.dart';
import 'package:flutter/material.dart';

class Notification extends StatefulWidget {
  static int HOURS_NOTIFICATION = 0;
  static int ANNOUNCEMENT_NOTIFICATION = 1;
  static int REMINDER_NOTIFICATION = 2;

  final int notificationType;
  final String header;
  final String summary;
  final String date;
  final Color fill;
  final String id;
  final Function(String?) navigateToHoursHistory;

  const Notification(
      {required this.notificationType, // Notification type from the above types
      required this.header, // Header string
      required this.summary, // Summary line
      required this.date, // Date of notification
      required this.id,
      required this.navigateToHoursHistory,
      this.fill = Colors.white,
      super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  @override
  Widget build(BuildContext context) {
    // Set notification icon
    IconData iconData =
        widget.notificationType == Notification.HOURS_NOTIFICATION
            ? Icons.access_time_sharp
            : (widget.notificationType == Notification.ANNOUNCEMENT_NOTIFICATION
                ? Icons.announcement
                : Icons.alarm);

    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: widget.fill,
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Icon(
              iconData,
              color: secondaryColour,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.summary,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.visible,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.date,
                      style: const TextStyle(fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.navigateToHoursHistory(widget.id);
                      },
                      child: Text(
                        'View',
                        style: TextStyle(fontSize: 12, color: primaryColour),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
