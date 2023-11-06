import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/get_line_graph_data.dart';
import 'package:cce_project/statistics/get_pie_chart_data.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class TeacherStatisticsPanelPage extends StatefulWidget {
  @override
  _TeacherStatisticsPanelPageState createState() =>
      _TeacherStatisticsPanelPageState();
}

class _TeacherStatisticsPanelPageState extends State<TeacherStatisticsPanelPage> {
  bool isLoading = false;
  FirestoreService firestoreService = FirestoreService(uid: FirebaseAuth.instance.currentUser!.uid);

  List allData = [];
  int numberOfColorsYouWant = 0;

  List<List<LineData>> _LineChartData = [];
  List<PieData> _PieChartData = [];
  List<PieData> _ColumnChartData = [];

  void loadHours() async {
    firestoreService.getAllLogs().then((data) {
      setState(() {
        allData = data;
        _LineChartData = GetLineGraphData(allData);
        _PieChartData = GetPieChartData(allData, "grade");
        _ColumnChartData = GetPieChartData(allData, "house");
        isLoading = false;
      });
    });
  }

  void loadUsers() async{

  }

  @override
  void initState(){
    super.initState();
    isLoading = true;
    loadHours();
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();
  late TooltipBehavior _tooltipBehavior;

  @override
  Widget build(BuildContext context) {
    List<int> list = [1, 2, 3];
    int year = DateTime.now().year;
    _tooltipBehavior = TooltipBehavior(enable: true);
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: !isLoading
                      ?SfCartesianChart(
                        title: ChartTitle(
                          text: 'Total Community Service hours in $year',
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
                      :const CircularProgressIndicator(color: primaryColour),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: SfCircularChart(
                    title: ChartTitle(
                      text: 'Total Community Service hours per grade in $year',
                      // Aligns the chart title to the center
                      alignment: ChartAlignment.center,
                      textStyle: const TextStyle(
                        fontSize: 20,
                      )
                    ),
                    // Palette colors
                    palette: getColors(_PieChartData.length, primaryColour),
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
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'Total Community Service hours per house in $year',
                        // Aligns the chart title to left
                        alignment: ChartAlignment.center,
                        textStyle: const TextStyle(
                          fontSize: 20,
                        )
                      ),
                      // Palette colors
                      palette: getColors(_ColumnChartData.length, secondaryColour),
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <ChartSeries<PieData, String>>[
                        ColumnSeries<PieData, String>(
                            dataSource: _ColumnChartData,
                            xValueMapper: (PieData data, _) => data.name,
                            yValueMapper: (PieData data, _) => data.hours,
                          )
                      ]
                    )
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
