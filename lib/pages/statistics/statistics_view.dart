import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monify/constants.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:d_chart/d_chart.dart';
import 'package:monify/models/category.dart';
import 'package:monify/pages/base/base_model.dart';
import 'package:monify/pages/statistics/statistics_controller.dart';
import 'package:monify/pages/statistics/statistics_model.dart';
import 'package:provider/provider.dart';

class StatisticsView extends StatefulWidget {
  BaseModel model;
  StatisticsView({Key? key, required this.model}) : super(key: key);

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late final StatisticsController _controller;
  late final StatisticsModel statisticsModel;

  //init state
  @override
  void initState() {
    super.initState();
    statisticsModel = StatisticsModel();
    _controller = StatisticsController(statisticsModel, widget.model);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: ((context) => statisticsModel),
        child: Scaffold(
          appBar: AppBar(
            // actions: [
            //   //filter
            //   IconButton(
            //     onPressed: () {},
            //     icon: const Icon(Icons.filter_list),
            //   ),
            // ],
            bottom: TabBar(
              tabs: [
                Tab(text: LocaleKeys.income.tr()),
                Tab(text: LocaleKeys.outcome.tr()),
                // Tab(text: LocaleKeys.transfer.tr()),
              ],
            ),
            title: const Text(LocaleKeys.statistics).tr(),
          ),
          body: Consumer<StatisticsModel>(builder: (context, model, child) {
            return TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Chart(model, _controller),
                      const SizedBox(height: 20),
                      StreamBuilder(builder: (context, snapshot) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.categories.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: _controller.calculateCategoryIncomeTotal(model.categories[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != 0) {
                                      return ListTile(
                                        title: Text(model.categories[index].name),
                                        trailing: Text(snapshot.data.toString()),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  });
                            });
                      }),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpenseChart(model, _controller),
                      const SizedBox(height: 20),
                      StreamBuilder(builder: (context, snapshot) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.categories.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                  future: _controller.calculateCategoryExpenseTotal(model.categories[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != 0) {
                                      return ListTile(
                                        title: Text(model.categories[index].name),
                                        trailing: Text(snapshot.data.toString()),
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  });
                            });
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class Chart extends StatefulWidget {
  const Chart(
    this.model,
    this.controller, {
    Key? key,
  }) : super(key: key);

  final StatisticsModel model;
  final StatisticsController controller;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  var chartData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChartData();
  }

  void getChartData() async {
    var data = await widget.controller.calculateIncomeChartData();
    setState(() {
      chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: chartData != null
            ? DChartPie(
                data: chartData,
                fillColor: (pieData, index) {
                  if (index! % 10 == 0) {
                    return kPrimaryColor;
                  } else if (index % 10 == 1) {
                    return Colors.blue;
                  } else if (index % 10 == 2) {
                    return Colors.green;
                  } else if (index % 10 == 3) {
                    return Colors.yellow;
                  } else if (index % 10 == 4) {
                    return Colors.orange;
                  } else if (index % 10 == 5) {
                    return Colors.purple;
                  } else if (index % 10 == 6) {
                    return Colors.pink;
                  } else if (index % 10 == 7) {
                    return Colors.red;
                  } else if (index % 10 == 8) {
                    return Colors.brown;
                  } else if (index % 10 == 9) {
                    return Colors.grey;
                  } else {
                    return Colors.black;
                  }
                },
                pieLabel: (pieData, index) {
                  return "${pieData['measure']}%:\n${pieData['domain']}";
                },
                labelPosition: PieLabelPosition.outside,
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  getPieChartColors(index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.blueAccent;
      case 2:
        return Colors.lightBlue;
      default:
        return kPrimaryColor;
    }
  }
}

class ExpenseChart extends StatelessWidget {
  const ExpenseChart(
    this.model,
    this.controller, {
    Key? key,
  }) : super(key: key);

  final StatisticsModel model;
  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.calculateExpenseChartData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DChartPie(
                data: snapshot.data!,
                fillColor: (pieData, index) {
                  if (index! % 10 == 0) {
                    return kPrimaryColor;
                  } else if (index % 10 == 1) {
                    return Colors.blue;
                  } else if (index % 10 == 2) {
                    return Colors.green;
                  } else if (index % 10 == 3) {
                    return Colors.yellow;
                  } else if (index % 10 == 4) {
                    return Colors.orange;
                  } else if (index % 10 == 5) {
                    return Colors.purple;
                  } else if (index % 10 == 6) {
                    return Colors.pink;
                  } else if (index % 10 == 7) {
                    return Colors.red;
                  } else if (index % 10 == 8) {
                    return Colors.brown;
                  } else if (index % 10 == 9) {
                    return Colors.grey;
                  } else {
                    return Colors.black;
                  }
                },
                pieLabel: (pieData, index) {
                  return "${pieData['measure']}%:\n${pieData['domain']}";
                },
                labelPosition: PieLabelPosition.outside,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
