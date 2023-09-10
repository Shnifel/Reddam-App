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
  static final List<String> _hoursTypes = ['Active', 'Passive'];
  static final List<String> _activeTypes = ['Collection', 'Time'];
  static final List<String> _passiveChoices = ['Donations', 'External'];
  static final List<String> _activeCollection = [
    'Blankets',
    'Bottle tops and tags',
    'Eco bricks',
    'External'
  ];
  static final List<String> _activeTime = [
    '67 hours',
    'Elandsvlei',
    'External',
    'Jars of hope',
    'Sandwiches',
    'Santa shoebox',
    'Squares',
    'Tutoring'
  ];

  static final List<DropdownMenuItem> grades = _grades.map((grade) {
    return DropdownMenuItem(value: grade, child: Text(grade));
  }).toList();

  static final List<DropdownMenuItem> houses = _houses.map((house) {
    return DropdownMenuItem(value: house, child: Text(house));
  }).toList();

  static final List<DropdownMenuItem> classes = _classes.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final List<DropdownMenuItem> hoursTypes = _hoursTypes.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final List<DropdownMenuItem> activeTypes = _activeTypes.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final List<DropdownMenuItem> passiveChoices = _passiveChoices.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final List<DropdownMenuItem> activeCollection =
      _activeCollection.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final List<DropdownMenuItem> activeTime = _activeTime.map((c) {
    return DropdownMenuItem(value: c, child: Text(c));
  }).toList();

  static final Map<String, List<DropdownMenuItem>> hoursChoices = {
    'Active': activeTypes,
    'Passive': passiveChoices,
    'Collection': activeCollection,
    'Time': activeTime
  };
}
