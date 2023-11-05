import 'package:cce_project/statistics/graph_data.dart';

List<PieData> GetPieChartData(List allData, String category) {

    //This will store the data for the graph
    List<PieData> PieChartData = [];

    List categories = [];

    if(category == "grade"){
      categories = ['8', '9', '10', '11', '12'];
    }

    else if(category == "class"){
      categories = ['A', 'D', 'E', 'H', 'M', 'R'];
    }

    else if(category == "house"){
      categories = ["Connaught", "Leinster", "Munster", "Ulster"];
    }

    //For each type
    for(int i = 0; i < categories.length; i++){
      PieChartData.add(PieData(categories[i], 0));
      //Loop through the databse results
      for(int j = 0; j < allData.length; j++){
        //Add up the hours
        if (allData[j][category] == categories[i]){
          PieChartData[i].hours += allData[j]["amount"];
        }
      }
    }

    //Round the data
    for(int i = 0; i < PieChartData.length; i++){
      String inString = PieChartData[i].hours.toStringAsFixed(2); 
      PieChartData[i].hours = double.parse(inString);
    }

    return PieChartData;
  }