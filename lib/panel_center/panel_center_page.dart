import 'package:cce_project/styles.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:cce_project/views/charts.dart';

class Todo {
  String name;
  bool enable;
  Todo({this.enable = true, required this.name});
}

class PanelCenterPage extends StatefulWidget {
  @override
  _PanelCenterPageState createState() => _PanelCenterPageState();
}

class _PanelCenterPageState extends State<PanelCenterPage> {
  List<Todo> _todos = [
    Todo(name: "Elandsvlei", enable: true),
    Todo(name: "Jars of hope", enable: true),
    Todo(name: "Sandwiches", enable: true),
    Todo(name: "Santa shoebox", enable: true),
    Todo(name: "Blankets", enable: true),
    Todo(name: "Squares", enable: true),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (ResponsiveLayout.isPhone(context))
            Container(
              color: primaryColour,
              width: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  /*borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),*/
                ),
              ),
            ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0 / 2, top: 10.0 / 2, right: 10.0 / 2),
                  child: Card(
                    color: secondaryColour,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: ListTile(
                        //leading: Icon(Icons.shopping_basket),
                        title: Text(
                          "Submissions verified",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "18% of submissions veried",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Chip(
                          label: Text(
                            "120",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                LineChartSample2(),
                PieChartSample2(),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0 / 2, bottom: 10.0, top: 10.0, left: 10.0 / 2),
                  child: Card(
                    color: primaryColour,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: List.generate(
                        _todos.length,
                        (index) => CheckboxListTile(
                          title: Text(
                            _todos[index].name,
                            style: TextStyle(color: Colors.white),
                          ),
                          value: _todos[index].enable,
                          onChanged: (newValue) {
                            setState(() {
                              _todos[index].enable = newValue ?? true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                BarChartSample2(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
