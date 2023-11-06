import 'dart:ffi';

import 'package:cce_project/statistics/graph_data.dart';

List<Student> GetLeaderboardtData(allData) {

    //This will store the data for the graph
    List<Student> LeaderboardData = [];

    List students = [];

    for(int i = 0; i < allData.length; i++){
      //If the list of students does not contain the current student, add them 
      if (!students.contains(allData[i]["uid"])){
        students.add(allData[i]["uid"]);
        LeaderboardData.add(Student(
          allData[i]["firstName"], 
          allData[i]["lastName"],
          allData[i]["grade"],
          allData[i]["class"],
          allData[i]["house"],
          0,
          0,
          0));
      }
    }

    //For each student
    for(int i = 0; i < students.length; i++){
      //Loop through the databse results
      for(int j = 0; j < allData.length; j++){
        //Add up the hours
        if (allData[j]["uid"] == students[i]){
          //Passive
          if(allData[j]["hours_type"] == "Passive"){
            LeaderboardData[i].passive += allData[j]["amount"];
            LeaderboardData[i].total += allData[j]["amount"];
          }
          //Active
          else if(allData[j]["hours_type"] == "Active"){
            LeaderboardData[i].active += allData[j]["amount"];
            LeaderboardData[i].total += allData[j]["amount"];
          }
        }
      }
    }

    LeaderboardData.sort((a, b) => a.total.compareTo(b.total));
    LeaderboardData = List.from(LeaderboardData.reversed);

    if(LeaderboardData.length > 10){
      LeaderboardData.removeRange(9, LeaderboardData.length - 1);
    }

    return LeaderboardData;
  }