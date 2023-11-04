import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/statistics/graph_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<List<LineData>> GetLineGraphData(allData) {

  DateTime now = DateTime.now(); // The current date

  List months = [];
  for(int i = 1; i < 13; i++){
    DateTime date = DateTime(now.year, i);
    months.add(date);
  }

  List categories = [
    "Active",
    "Passive"
  ];

  //This will store the yield of each category in a specific month (initialise all yields to 0)
  List<double> monthlyHours = List.filled(categories.length, 0);

  //This will store the line graph data for each category
  List<List<LineData>> data = [];
  for(int i = 0; i < categories.length; i++){
    data.add([]);
  }

  //For each month
  for(int i = 0; i < 12; i++){
    //Loop through the database results
    for(int j = 0; j < allData.length; j++){
      // Convert firestore timestamp to DateTime
      DateTime date = DateTime.parse(allData[j]["date"].toDate().toString());
      for(int k = 0; k < categories.length; k++){
        //Add up the hours
        if (months[i].month == date.month && allData[j]["hours_type"] == categories[k]){
          monthlyHours[k] += allData[j]["amount"];
        }
      }
    }

    for(int k = 0; k < categories.length; k++){
      data[k].add(LineData(months[i], monthlyHours[k], categories[k]));
    }

    //Reset counts
    monthlyHours = List.filled(categories.length, 0);
  }

  return data;
}

