import 'package:cce_project/styles.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:flutter/material.dart';

List<String> _buttonNames = [
  "Home",
  "Settings",
  "Notifications",
  "Statistics",
  "Timetable",
  "Log Hours",
  "Edit User",
  "Users",
  "Hours summary",
  "Logout"
];
int _currentSelectedButton2 = 0;

class AppBarWidget extends StatefulWidget {
  final int _currentSelectedButton;

  AppBarWidget(this._currentSelectedButton);

  @override
  _AppBarWidgetState createState() =>
      _AppBarWidgetState(_currentSelectedButton);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final int _currentSelectedButton;

  _AppBarWidgetState(this._currentSelectedButton);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColour,
      child: Row(
        children: [
          if (ResponsiveLayout.isComputer(context))
            Container(
              margin: const EdgeInsets.all(10.0),
              height: double.infinity,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 0),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ], shape: BoxShape.circle),
              child: const CircleAvatar(
                backgroundColor: primaryColour,
                radius: 30,
                //child: Image.asset("assets/images/ReddamHouseLogo.svg.png"),
              ),
            )
          else
            IconButton(
              padding: const EdgeInsets.only(left: 10, top: 60),
              color: Colors.white,
              iconSize: 30,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
          SizedBox(width: 10.0),
          if (ResponsiveLayout.isComputer(context))
            OutlinedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(10.0 / 2),
                child: Text("Teacher Panel"),
              ),
              style: OutlinedButton.styleFrom(
                  primary: Colors.white,
                  side: BorderSide(color: Colors.white, width: 0.4)),
            ),
          Spacer(),
          if (ResponsiveLayout.isComputer(context))
            ...List.generate(
              _buttonNames.length,
              (index) => TextButton(
                onPressed: () {
                  setState(() {
                    _currentSelectedButton2 = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0 * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _buttonNames[index],
                        style: TextStyle(
                          color: _currentSelectedButton2 == index
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10.0 / 2),
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: _currentSelectedButton2 == index
                              ? const LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _buttonNames[_currentSelectedButton],
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0 / 2),
                    width: 60,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: secondaryColour,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.only(top: 60),
            color: Colors.white,
            iconSize: 30,
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          Stack(
            children: [
              IconButton(
                padding: const EdgeInsets.only(right: 10, top: 60),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_outlined),
              ),
              // Positioned(
              //   right: 10,
              //   top: 10,
              //   child: CircleAvatar(
              //     backgroundColor: Colors.pink,
              //     radius: 8,
              //     child: Text(
              //       "3",
              //       style: TextStyle(fontSize: 10, color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
          if (!ResponsiveLayout.isPhone(context))
            Container(
              margin: const EdgeInsets.all(10.0),
              height: double.infinity,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 0),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ], shape: BoxShape.circle),
              child: const CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 30,
              ),
            ),
        ],
      ),
    );
  }
}
