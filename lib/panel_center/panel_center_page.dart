import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/get_leaderboard_data.dart';
import 'package:cce_project/statistics/get_pie_chart_data.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isLoading = false;
  FirestoreService firestoreService = FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);

  List allData = [];
  List allDataCopy = [];
  List<PieData> _gradeAllData = [];
  List<PieData> _grade8Data = [];
  List<PieData> _grade9Data = [];
  List<PieData> _grade10Data = [];
  List<PieData> _grade11Data = [];
  List<PieData> _grade12Data = [];
  List<PieData> _houseData = [];
  List<Student> _studentData = <Student>[];

  String topGrade = "";
  String topClass8 = "";
  String topClass9 = "";
  String topClass10 = "";
  String topClass11 = "";
  String topClass12 = "";
  String topHouse = "";
  String topStudent = "";

  void loadHours() async {
    firestoreService.getAllLogs().then((data) {
      setState(() {
        // Retrieve and organise data
        allData = data;
        _gradeAllData = GetPieChartData(allData, "grade");
        _houseData = GetPieChartData(allData, "house");
        _studentData = GetLeaderboardtData(allData);

        // Retrieve top grade
        _gradeAllData.sort((a, b) => a.hours.compareTo(b.hours));
        _gradeAllData = List.from(_gradeAllData.reversed);
        topGrade = _gradeAllData[0].name;

        // Retrieve top house
        _houseData.sort((a, b) => a.hours.compareTo(b.hours));
        _houseData = List.from(_houseData.reversed);
        topHouse = _houseData[0].name;

        // Retrieve top student
        String firstName = _studentData[0].firstName;
        String lastName = _studentData[0].lastName;
        topStudent = '$firstName $lastName';
        isLoading = false;

        // Retrieve top class in grade 8
        allDataCopy = List.from(allData);
        allDataCopy.removeWhere((element) => element["grade"] != "8");
        _grade8Data = GetPieChartData(allDataCopy, "class");
        _grade8Data.sort((a, b) => a.hours.compareTo(b.hours));
        _grade8Data = List.from(_grade8Data.reversed);
        topClass8 = _grade8Data[0].name;

        // Retrieve top class in grade 9
        allDataCopy = List.from(allData);
        allDataCopy.removeWhere((element) => element["grade"] != "9");
        _grade9Data = GetPieChartData(allDataCopy, "class");
        _grade9Data.sort((a, b) => a.hours.compareTo(b.hours));
        _grade9Data = List.from(_grade9Data.reversed);
        topClass9 = _grade9Data[0].name;

        // Retrieve top class in grade 10
        allDataCopy = List.from(allData);
        allDataCopy.removeWhere((element) => element["grade"] != "10");
        _grade10Data = GetPieChartData(allDataCopy, "class");
        _grade10Data.sort((a, b) => a.hours.compareTo(b.hours));
        _grade10Data = List.from(_grade10Data.reversed);
        topClass10 = _grade10Data[0].name;

        // Retrieve top class in grade 11
        allDataCopy = List.from(allData);
        allDataCopy.removeWhere((element) => element["grade"] != "11");
        _grade11Data = GetPieChartData(allDataCopy, "class");
        _grade11Data.sort((a, b) => a.hours.compareTo(b.hours));
        _grade11Data = List.from(_grade11Data.reversed);
        topClass11 = _grade11Data[0].name;

        // Retrieve top class in grade 12
        allDataCopy = List.from(allData);
        allDataCopy.removeWhere((element) => element["grade"] != "12");
        _grade12Data = GetPieChartData(allDataCopy, "class");
        _grade12Data.sort((a, b) => a.hours.compareTo(b.hours));
        _grade12Data = List.from(_grade12Data.reversed);
        topClass12 = _grade12Data[0].name;


      });
    });
  }

  @override
  void initState(){
    super.initState();
    isLoading = true;
    loadHours();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          !isLoading ?SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10), 
                  child: Text("Top Student", style: TextStyle(fontSize: 30))
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child:
                          Image.asset("assets/images/Student.png"),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10), 
                  child: Text(topStudent, style: const TextStyle(fontSize: 24))
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10), 
                      child: Text("Top House", style: TextStyle(fontSize: 30))
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10), 
                      child: Text("Top Grade", style: TextStyle(fontSize: 30))
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child:
                          Image.asset("assets/images/House.png"),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child:
                          Image.asset("assets/images/Grade.png"),
                    ),
                  ],
                ), 
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(topHouse, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(topGrade, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10), 
                  child: Text("Top Class", style: TextStyle(fontSize: 30))
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5.5,
                      child:
                          Image.asset("assets/images/Class_8.png"),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5.5,
                      child:
                          Image.asset("assets/images/Class_9.png"),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5.5,
                      child:
                          Image.asset("assets/images/Class_10.png"),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5.5,
                      child:
                          Image.asset("assets/images/Class_11.png"),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5.5,
                      child:
                          Image.asset("assets/images/Class_12.png"),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(topClass8, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(topClass9, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(topClass10, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(topClass11, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Text(topClass12, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                      ),
                    ],
                  ),
                ),              
              ],
            ),
          )
          : const Center(child: CircularProgressIndicator(color: primaryColour)),
        ],
      ),
    );
  }
}
