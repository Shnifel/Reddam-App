import 'package:cce_project/views/hours_log_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoursLog extends StatefulWidget {
  const HoursLog({super.key});

  @override
  State<HoursLog> createState() => _HoursLogState();
}

class _HoursLogState extends State<HoursLog> {
  bool _isSuccess = false;

  void onSuccess() {
    setState(() {
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LogHoursPage(isSuccess: _isSuccess, onSuccess: onSuccess);
  }
}
