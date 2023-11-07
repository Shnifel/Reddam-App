import 'package:cce_project/helpers/date_forrmater.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/widgets/hours_card.dart';
import 'package:cce_project/widgets/hours_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class HoursHistoryPage extends StatefulWidget {
  String? focus;

  HoursHistoryPage({this.focus, super.key});

  @override
  State<HoursHistoryPage> createState() => _HoursHistoryPageState();
}

class _HoursHistoryPageState extends State<HoursHistoryPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> hours = [];
  List<String> filters = ['Approved', 'Pending', 'Rejected'];
  List<bool> selected = [false, false, false];
  List<Color> filter_colors = [Colors.green, Colors.yellow, Colors.red];
  FirestoreService firestoreService =
      FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);
  int count = 0;
  ScrollController _scrollController = ScrollController();
  GlobalKey _focusKey = GlobalKey();

  void loadHours({Map<String, Object?> filters = const {}}) async {
    firestoreService.getStudentLogs(filters: filters).then((data) {
      setState(() {
        hours = data;
        print(data);
        isLoading = false;
      });
      if (widget.focus != null) {
        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
          _scrollController.animateTo(_focusKey.currentContext!.size!.height,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          widget.focus = null;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadHours();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator(color: primaryColour)
        : Padding(
            padding: const EdgeInsets.all(0),
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text('My hours',
                        style: loginPageText.copyWith(
                            fontSize: 35, fontWeight: FontWeight.bold))),
                Row(
                    children: List.generate(
                        filters.length,
                        (index) => Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                            child: FilterChip(
                                padding: EdgeInsets.all(10),
                                selected: selected[index],
                                backgroundColor: selected[index]
                                    ? filter_colors[index]
                                    : Colors.grey.withOpacity(0.4),
                                selectedColor: filter_colors[index],
                                label: Text(filters[index]),
                                showCheckmark: false,
                                onSelected: (isSelected) {
                                  if (selected[index]) {
                                    setState(() {
                                      selected[index] = false;
                                      isLoading = true;
                                      loadHours();
                                    });
                                  } else {
                                    setState(() {
                                      for (int i = 0;
                                          i < selected.length;
                                          i++) {
                                        selected[i] = false;
                                      }
                                      selected[index] = true;
                                      isLoading = true;
                                      Map<String, Object> filter = {};
                                      filter['validated'] =
                                          filters[index] != 'Pending';
                                      if (filter['validated'] == true) {
                                        filter['accepted'] =
                                            filters[index] == 'Approved';
                                      }

                                      loadHours(filters: filter);
                                    });
                                  }
                                })))),
                Column(
                    children: hours.isNotEmpty
                        ? hours.map((notif) {
                            count += 1;
                            return Padding(
                                key: notif['id'] == widget.focus
                                    ? _focusKey
                                    : null,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: HoursCard(
                                    header:
                                        "${notif['hours_type']} - ${notif['active_type'] == null ? notif['activity'] : notif['active_type']}",
                                    summary:
                                        "${notif['amount']} new hours logged",
                                    date: DateFormatter.formatRelativeDate(
                                        (notif['date'] as Timestamp).toDate()),
                                    status: notif['validated']
                                        ? notif['accepted']
                                            ? HoursCard.APPROVED
                                            : HoursCard.REJECTED
                                        : HoursCard.PENDING,
                                    fill: notif['id'] == widget.focus
                                        ? primaryColour.withOpacity(0.2)
                                        : Colors.white,
                                    body: HoursLogInfo(
                                      hoursInfo: notif,
                                    )));
                          }).toList()
                        : [
                            const Text(
                              "Nothing to see here",
                              textAlign: TextAlign.center,
                            )
                          ])
              ],
            ));
  }
}
