import 'package:cce_project/services/database.dart';
import 'package:flutter/material.dart';

class BadgeNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  BadgeNotifier() {
    _initBadgeCount();
  }

  Future<void> _initBadgeCount() async {
    int recordCount = await LocalDatabaseProvider().getUnreadCount();
    _count = recordCount;
    notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
    // Notify listeners when the state changes
  }

  void reset() {
    _count = 0;
    LocalDatabaseProvider().clearUnreadNotifications();
    notifyListeners();
  }
}
