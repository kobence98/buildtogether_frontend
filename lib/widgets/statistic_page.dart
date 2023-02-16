import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/age_bracket.dart';
import 'package:flutter_frontend/entities/gender.dart';
import 'package:flutter_frontend/entities/living_place_type.dart';
import 'package:flutter_frontend/entities/salary_type.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../entities/statistic_data.dart';

class StatisticPage extends StatefulWidget {
  final int postId;
  final Session session;
  final Languages languages;

  const StatisticPage(
      {Key? key,
      required this.postId,
      required this.session,
      required this.languages})
      : super(key: key);

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  late Languages languages;
  late StatisticData statisticData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: true,
              title: Center(
                child: Text(
                  languages.statisticLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            body: loading
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
                    ),
                  )
                : _chartsWidget()));
  }

  void _initData() async {
    dynamic response =
        await widget.session.get('/api/posts/${widget.postId}/statisticData');
    if (response.statusCode == 200) {
      dynamic body = json.decode(utf8.decode(response.bodyBytes));
      statisticData = StatisticData.fromJson(body);
    } else {
      Fluttertoast.showToast(
          msg: languages.locationErrorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {
      loading = false;
    });
  }

  _chartsWidget() {
    return Container(
      color: Colors.black,
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Text(
                    languages.livingPlaceTypeLabel,
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: SfCartesianChart(
                      borderWidth: 10,
                      plotAreaBorderColor: Colors.white,
                      plotAreaBorderWidth: 2,
                      primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.6,
                            color: Colors.grey
                        ),
                          labelStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          borderColor: Colors.white,
                          maximum: statisticData
                                  .livingPlaceTypeStatistics.values
                                  .reduce(max)
                                  .toDouble() +
                              10,
                          interval: ((statisticData
                                              .livingPlaceTypeStatistics.values
                                              .reduce(max)
                                              .toDouble() ~/
                                          10)
                                      .toDouble() !=
                                  0
                              ? (statisticData.livingPlaceTypeStatistics.values
                                          .reduce(max)
                                          .toDouble() ~/
                                      10)
                                  .toDouble() * 3
                              : 1) * 5),
                      series: <ColumnSeries<MapEntry<String, int>, String>>[
                        // Initialize line series.
                        ColumnSeries<MapEntry<String, int>, String>(
                            color: Colors.lime,
                            dataSource: statisticData.livingPlaceTypeStatistics
                                .map((key, value) =>
                                    MapEntry(key.getName(languages), value))
                                .entries
                                .toList(),
                            xValueMapper: (MapEntry<String, int> data, _) =>
                                data.key,
                            yValueMapper: (MapEntry<String, int> data, _) =>
                                data.value)
                      ]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Text(
                    languages.ageLabel,
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: SfCartesianChart(
                      borderWidth: 10,
                      plotAreaBorderColor: Colors.white,
                      plotAreaBorderWidth: 2,
                      primaryXAxis: CategoryAxis(
                          labelRotation: 90,
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.6,
                            color: Colors.grey
                        ),
                          labelStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          borderColor: Colors.white,
                          maximum: statisticData.ageStatistics.values
                                  .reduce(max)
                                  .toDouble() +
                              10,
                          interval: ((statisticData.ageStatistics.values
                                              .reduce(max)
                                              .toDouble() ~/
                                          10)
                                      .toDouble() !=
                                  0
                              ? (statisticData.ageStatistics.values
                                          .reduce(max)
                                          .toDouble() ~/
                                      10)
                                  .toDouble()
                              : 1) * 5),
                      series: <ColumnSeries<MapEntry<String, int>, String>>[
                        // Initialize line series.
                        ColumnSeries<MapEntry<String, int>, String>(
                            color: Colors.lime,
                            dataSource: statisticData.ageStatistics
                                .map((key, value) =>
                                    MapEntry(key.getName, value))
                                .entries
                                .toList(),
                            xValueMapper: (MapEntry<String, int> data, _) =>
                                data.key,
                            yValueMapper: (MapEntry<String, int> data, _) =>
                                data.value)
                      ]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Text(
                    languages.genderLabel,
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: SfCartesianChart(
                      borderWidth: 10,
                      plotAreaBorderColor: Colors.white,
                      plotAreaBorderWidth: 2,
                      primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.6,
                            color: Colors.grey
                        ),
                          labelStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          borderColor: Colors.white,
                          maximum: statisticData.genderStatistics.values
                                  .reduce(max)
                                  .toDouble() +
                              10,
                          interval: ((statisticData.genderStatistics.values
                                              .reduce(max)
                                              .toDouble() ~/
                                          10)
                                      .toDouble() !=
                                  0
                              ? (statisticData.genderStatistics.values
                                          .reduce(max)
                                          .toDouble() ~/
                                      10)
                                  .toDouble()
                              : 1) * 5),
                      series: <ColumnSeries<MapEntry<String, int>, String>>[
                        // Initialize line series.
                        ColumnSeries<MapEntry<String, int>, String>(
                            color: Colors.lime,
                            dataSource: statisticData.genderStatistics
                                .map((key, value) =>
                                    MapEntry(key.getName(languages), value))
                                .entries
                                .toList(),
                            xValueMapper: (MapEntry<String, int> data, _) =>
                                data.key,
                            yValueMapper: (MapEntry<String, int> data, _) =>
                                data.value)
                      ]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Text(
                    languages.salaryTypeLabel,
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  // height: 400,
                  child: SfCartesianChart(
                      borderWidth: 10,
                      plotAreaBorderColor: Colors.white,
                      plotAreaBorderWidth: 2,
                      primaryXAxis: CategoryAxis(
                          labelRotation: 90,
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.6,
                            color: Colors.grey
                        ),
                          labelStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          borderColor: Colors.white,
                          maximum: statisticData.salaryTypeStatistics.values
                                  .reduce(max)
                                  .toDouble() +
                              10,
                          interval: ((statisticData.salaryTypeStatistics.values
                                              .reduce(max)
                                              .toDouble() ~/
                                          10)
                                      .toDouble() !=
                                  0
                              ? (statisticData.salaryTypeStatistics.values
                                          .reduce(max)
                                          .toDouble() ~/
                                      10)
                                  .toDouble()
                              : 1) * 5),
                      series: <ColumnSeries<MapEntry<String, int>, String>>[
                        // Initialize line series.
                        ColumnSeries<MapEntry<String, int>, String>(
                            color: Colors.lime,
                            dataSource: statisticData.salaryTypeStatistics
                                .map((key, value) =>
                                    MapEntry(key.getName(languages), value))
                                .entries
                                .toList(),
                            xValueMapper: (MapEntry<String, int> data, _) =>
                                data.key,
                            yValueMapper: (MapEntry<String, int> data, _) =>
                                data.value)
                      ]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Text(
                    languages.numberOfHouseholdMembersLabel,
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: SfCartesianChart(
                      borderWidth: 10,
                      plotAreaBorderColor: Colors.white,
                      plotAreaBorderWidth: 2,
                      primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.6,
                            color: Colors.grey
                        ),
                          labelStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          borderColor: Colors.white,
                          maximum: statisticData
                                  .numberOfHouseholdMembersStatistics.values
                                  .reduce(max)
                                  .toDouble() +
                              10,
                          interval: ((statisticData
                                              .numberOfHouseholdMembersStatistics
                                              .values
                                              .reduce(max)
                                              .toDouble() ~/
                                          10)
                                      .toDouble() !=
                                  0
                              ? (statisticData
                                          .numberOfHouseholdMembersStatistics
                                          .values
                                          .reduce(max)
                                          .toDouble() ~/
                                      10)
                                  .toDouble()
                              : 1) * 5),
                      series: <ColumnSeries<MapEntry<String, int>, String>>[
                        // Initialize line series.
                        ColumnSeries<MapEntry<String, int>, String>(
                            color: Colors.lime,
                            dataSource: statisticData
                                .numberOfHouseholdMembersStatistics
                                .map((key, value) =>
                                    MapEntry(key.toString(), value))
                                .entries
                                .toList(),
                            xValueMapper: (MapEntry<String, int> data, _) =>
                                data.key,
                            yValueMapper: (MapEntry<String, int> data, _) =>
                                data.value)
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
