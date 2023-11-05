import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/get_line_graph_data.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TeacherStatisticsPanelPage extends StatefulWidget {
  @override
  _TeacherStatisticsPanelPageState createState() =>
      _TeacherStatisticsPanelPageState();
}

class _TeacherStatisticsPanelPageState extends State<TeacherStatisticsPanelPage> {
  bool isLoading = true;
  FirestoreService firestoreService = FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);

  List allData = [];

  List<List<LineData>> _LineChartData = [];
  //List<PieData> _PieChartData = [];

  void loadHours({Map<String, Object?> filters = const {}}) async {
    firestoreService.getAllLogs().then((data) {
      setState(() {
        allData = data;
        _LineChartData = GetLineGraphData(allData);
        isLoading = false;
      });
      // if (widget.focus != null) {
      //   SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      //     _scrollController.animateTo(_focusKey.currentContext!.size!.height,
      //         duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      //     widget.focus = null;
      //   });
      // }
    });
  }

  @override
  void initState(){
    super.initState();
    loadHours();
  }

  late TooltipBehavior _tooltipBehavior;

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior = TooltipBehavior(enable: true);
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // const SizedBox(
                //   height: 30.0,
                //   child: Text(
                //     'Direct Emissions by lpg-cooking, lpg-lab  and diesel (in kg)',
                //     style: loginPageText,
                //   ),
                // ),
                Container(
                  height: 400,
                  child: SfCartesianChart(
                      legend: const Legend(
                        isVisible: true, 
                        // Overflowing legend content will be wraped
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                      ),
                      //plotAreaBackgroundColor: primaryColour,
                      // Palette colors
                      palette: const <Color>[
                          primaryColour,
                          secondaryColour,
                      ],
                      //Enables the tooltip for all the series
                      tooltipBehavior: _tooltipBehavior,
                      //This allows us to not have to specify how many lines there will be
                      series: getLineSeries(_LineChartData),
                      primaryXAxis: DateTimeAxis(
                            edgeLabelPlacement: EdgeLabelPlacement.shift, 
                            // Interval type will be months
                            intervalType: DateTimeIntervalType.months,
                            dateFormat: DateFormat.MMM(),
                            
                            interval: 1),
                      primaryYAxis: NumericAxis(labelFormat: '{value}')
                    )
                  ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.red,
                  // ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.amber,
                  // ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.blue,
                  // ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.red,
                  // ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.amber,
                  // ),
                  // Container(
                  //   height: 200,
                  //   width: double.infinity,
                  //   color: Colors.blue,
                  // )
              ]
            )
        )
      ));
  }

  List<SplineSeries<LineData, DateTime>> getLineSeries(List _LineChartData) {
    List<SplineSeries<LineData, DateTime>> lineSeries = [];
    for (int i = 0; i < _LineChartData.length; i++) {
      lineSeries.add(SplineSeries<LineData, DateTime>(
        dataSource: _LineChartData[i],
        xValueMapper: (LineData x, _) => x.time,
        yValueMapper: (LineData x, _) => x.hours,
        // Line width
        width: 3,
        name: _LineChartData[i][0].name
        )
      );
    }
    return lineSeries;
  }

}
