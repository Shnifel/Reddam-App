import 'package:cce_project/helpers/date_forrmater.dart';
import 'package:cce_project/services/badge_notifier.dart';
import 'package:cce_project/services/database.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/widgets/hours_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cce_project/widgets/notification.dart' as Notification;
import 'package:flutter_filter_dialog/flutter_filter_dialog.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  final Function(String?) navigateToHoursHistory;
  const NotificationsPage({required this.navigateToHoursHistory, super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> new_notifications = [];
  List<String> filters = ['Approved', 'Pending', 'Rejected'];
  List<bool> selected = [false, false, false];
  List<Color> filter_colors = [Colors.green, Colors.yellow, Colors.red];
  FirestoreService firestoreService =
      FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);
  int count = 0;

  void loadNotifications({Map<String, Object?> filters = const {}}) async {
    LocalDatabaseProvider localDatabaseProvider = LocalDatabaseProvider();

    localDatabaseProvider.getNotifications().then((data) => setState(
          () {
            notifications = data;
            isLoading = false;
          },
        ));

    localDatabaseProvider.getUnreadNotifications().then((data) => setState(
          () {
            new_notifications = data;
            print(data);
            Provider.of<BadgeNotifier>(context, listen: false).reset();
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator(color: primaryColour)
        : Padding(
            padding: EdgeInsets.all(0),
            child: ListView(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text('Notifications',
                        style: loginPageText.copyWith(
                            fontSize: 35, fontWeight: FontWeight.bold))),
                Column(
                    children: notifications.isNotEmpty
                        ? notifications.map((notif) {
                            return Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Notification.Notification(
                                  id: notif['id'],
                                  navigateToHoursHistory:
                                      widget.navigateToHoursHistory,
                                  header: "",
                                  summary: notif['message'],
                                  notificationType: Notification
                                      .Notification.HOURS_NOTIFICATION,
                                  date: DateFormatter.formatRelativeDate(
                                      DateTime.parse(notif['date'])),
                                  fill: new_notifications.any(
                                          (map) => map['id'] == notif['id'])
                                      ? primaryColour.withOpacity(0.2)
                                      : Colors.white,
                                ));
                          }).toList()
                        : [
                            Text(
                              "Nothing to see here",
                              textAlign: TextAlign.center,
                            )
                          ])
              ],
            ));
  }
}
