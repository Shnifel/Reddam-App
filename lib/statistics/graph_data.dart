import 'dart:ffi';

class LineData{
  LineData(this.time, this.hours, this.name);
  final DateTime time;
  final double hours;
  final String name;
}

class PieData {
  PieData(this.name, this.hours);
  String name;
  double hours; 
}

class Student {
  Student(this.firstName, this.lastName, this.grade, this.clas, this.house, this.passive, this.active, this.total);
  final String firstName;
  final String lastName;
  final String grade;
  final String clas;
  final String house;
  double passive;
  double active;
  double total;
}