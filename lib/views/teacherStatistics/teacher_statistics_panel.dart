import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/get_line_graph_data.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
    List<int> list = [1, 2, 3, 4, 5];
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom - kToolbarHeight;
    int _current = 0;
    final CarouselController _controller = CarouselController();
    return Scaffold(
      appBar: null,
      body: Container(
        child: CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            aspectRatio: width / newheight,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            //enlargeCenterPage: true,
            enlargeFactor: 0.3,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          items: list
              .map((item) => Container(
                    child: Center(child: Text(item.toString())),
                    color: Colors.green,
                  ))
              .toList(),
        )),
    );
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
