import 'package:flutter/material.dart';

class DropdownListHelper {
  static final List<String> _grades = ['8', '9', '10', '11', '12'];
  static final List<String> _houses = [
    'Connaught',
    'Leinster',
    'Munster',
    'Ulster'
  ];
  static final List<String> _classes = ['R', 'E', 'D', 'A', 'M', 'H'];

  static final List<DropdownMenuItem> grades = _grades.map((grade) {
    return DropdownMenuItem(value: grade, child: Text(grade));
  }).toList();

  static final List<DropdownMenuItem> houses = _houses.map((house) {
    return DropdownMenuItem(value: house, child: Text(house));
  }).toList();

  static final List<DropdownMenuItem> classes = _classes.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();
}
