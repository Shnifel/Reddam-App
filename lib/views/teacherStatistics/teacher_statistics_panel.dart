import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/data_source.dart';
import 'package:cce_project/statistics/get_leaderboard_data.dart';
import 'package:cce_project/statistics/get_line_graph_data.dart';
import 'package:cce_project/statistics/get_pie_chart_data.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TeacherStatisticsPanelPage extends StatefulWidget {
  @override
  _TeacherStatisticsPanelPageState createState() =>
      _TeacherStatisticsPanelPageState();
}

class _TeacherStatisticsPanelPageState extends State<TeacherStatisticsPanelPage> {
  bool isLoading = false;
  FirestoreService firestoreService = FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);

  List allData = [];

  List<List<LineData>> _LineChartData = [];
  List<PieData> _PieChartData = [];
  List<PieData> _ColumnChartData = [];
  List<Student> _LeaderboardData = <Student>[];
  late StudentDataSource _studentDataSource;

  void loadHours() async {
    firestoreService.getAllLogs().then((data) {
      setState(() {
        allData = data;
        _LineChartData = GetLineGraphData(allData);
        _PieChartData = GetPieChartData(allData, "grade");
        _ColumnChartData = GetPieChartData(allData, "house");
        _LeaderboardData = GetLeaderboardtData(allData);
        _studentDataSource = StudentDataSource(students: _LeaderboardData);
        isLoading = false;
      });
    });
  }

  @override
  void initState(){
    super.initState();
    isLoading = true;
    loadHours();
    _studentDataSource = StudentDataSource(students: _LeaderboardData);
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();
  late TooltipBehavior _tooltipBehaviorLine;
  late TooltipBehavior _tooltipBehaviorPie;
  late TooltipBehavior _tooltipBehaviorBar;

  @override
  Widget build(BuildContext context) {
    List<int> list = [1, 2, 3, 4];
    int year = DateTime.now().year;
    _tooltipBehaviorLine = TooltipBehavior(enable: true);
    _tooltipBehaviorPie = TooltipBehavior(enable: true, format: 'Grade point.x : point.y hours');
    _tooltipBehaviorBar = TooltipBehavior(enable: true, header: "", canShowMarker: false);
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: [
                // LINE GRAPH
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: !isLoading
                      ?SfCartesianChart(
                        title: ChartTitle(
                          text: 'Total Community Service Hours in $year',
                          // Aligns the chart title to left
                          alignment: ChartAlignment.near,
                          textStyle: const TextStyle(
                            fontSize: 20,
                          )
                        ),
                        legend: const Legend(
                          isVisible: true, 
                          // Overflowing legend content will be wrapped
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
                        tooltipBehavior: _tooltipBehaviorLine,
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
                      :const CircularProgressIndicator(color: primaryColour),
                  ),
                ),
                // PIE CHART
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: SfCircularChart(
                    title: ChartTitle(
                      text: 'Total Community Service Hours per Grade in $year',
                      // Aligns the chart title to the center
                      alignment: ChartAlignment.center,
                      textStyle: const TextStyle(
                        fontSize: 20,
                      )
                    ),
                    // Palette colors
                    palette: getColors(_PieChartData.length, primaryColour),
                    //Enables the tooltip for all the series
                    tooltipBehavior: _tooltipBehaviorPie,
                    legend: const Legend(
                      isVisible: true,
                      // Overflowing legend content will be wrapped
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom,
                      title: LegendTitle(
                        text: "Grade", 
                        textStyle: TextStyle(
                          color: primaryColour,
                          fontSize: 25,
                        )
                      )
                    ),
                    series: <CircularSeries>[
                      // Render pie chart
                      PieSeries<PieData, String>(
                        dataSource: _PieChartData,
                        xValueMapper: (PieData data, _) => data.name,
                        yValueMapper: (PieData data, _) => data.hours,
                        dataLabelSettings: const DataLabelSettings(
                          // Renders the data label
                          isVisible: true
                        )
                      )
                    ]
                  )
                ),
                // BAR GRAPH
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'Total Community Service Hours per House in $year',
                        // Aligns the chart title to left
                        alignment: ChartAlignment.center,
                        textStyle: const TextStyle(
                          fontSize: 20,
                        )
                      ),
                      //Enables the tooltip for all the series
                      tooltipBehavior: _tooltipBehaviorBar,
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <ChartSeries<PieData, String>>[
                        ColumnSeries<PieData, String>(
                            dataSource: _ColumnChartData,
                            xValueMapper: (PieData data, _) => data.name,
                            yValueMapper: (PieData data, _) => data.hours,
                            onCreateRenderer: (ChartSeries<PieData, String> series) {
                              return _CustomColumnSeriesRenderer();
                            },
                            color: Colors.black
                          )
                      ]
                    )
                ),
                // LEADERBOARD
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Text("Student Leaderboard", style: TextStyle(fontSize: 25),),
                    ),
                    Expanded(
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: secondaryColour),
                        child: SfDataGrid(
                          columnWidthMode: ColumnWidthMode.fill,
                          source: _studentDataSource,
                          columns: [
                            GridColumn(
                                columnName: 'firstName',
                                label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'First Name',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'lastName',
                                label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Last Name',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'grade',
                                label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Grade',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'total',
                                label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Total Hours',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                          ],
                      )),
                    ),
                  ],
                ),
              ],
              carouselController: _controller,
              options: CarouselOptions(
                  autoPlay: false,
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  aspectRatio: 0.65,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.only(bottom: 30, left: 4, right: 4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
      ]
        ),
    );
  }

  List<LineSeries<LineData, DateTime>> getLineSeries(List _LineChartData) {
    List<LineSeries<LineData, DateTime>> lineSeries = [];
    for (int i = 0; i < _LineChartData.length; i++) {
      lineSeries.add(LineSeries<LineData, DateTime>(
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

  // Function to generate shades of the primary color
  List<Color> getColors(n, col){
    List<Color> c = <Color>[];
    var hsl = HSLColor.fromColor(col);
    c.add(hsl.toColor());
    for(int i = 0; i < n-1; i++){
      final hslLight = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0));
      hsl = hslLight;
      c.add(hslLight.toColor());
    }
    return c;
  }

}

class _ColumnCustomPainter extends ColumnSegment {
  @override
  int get currentSegmentIndex => super.currentSegmentIndex!;

  @override
   void onPaint(Canvas canvas) {
     final List<LinearGradient> gradientList = <LinearGradient>[
       const LinearGradient(
         colors: <Color>[Color.fromRGBO(59,98,125,1), Color.fromRGBO(59,98,125,1)],
       ),
       const LinearGradient(
         colors: <Color>[Color.fromRGBO(1,92,67,1), Color.fromRGBO(1,92,67,1)],
       ),
       const LinearGradient(
         colors: <Color>[Color.fromRGBO(124,44,119, 1), Color.fromRGBO(124,44,119, 1)],
       ),
       const LinearGradient(
         colors: <Color>[Color.fromRGBO(141,1,38,1), Color.fromRGBO(141,1,38,1)],
       ),
    ];
 
    fillPaint!.shader =
        gradientList[currentSegmentIndex].createShader(segmentRect.outerRect);
    
    super.onPaint(canvas);
   }
}

class _CustomColumnSeriesRenderer extends ColumnSeriesRenderer {
  _CustomColumnSeriesRenderer();
  @override
  ChartSegment createSegment() {
    return _ColumnCustomPainter();
  }
}
