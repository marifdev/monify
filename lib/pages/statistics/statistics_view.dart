import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monify/constants.dart';
import 'package:monify/generated/locale_keys.g.dart';
import 'package:d_chart/d_chart.dart';
import 'package:monify/models/category.dart';
import 'package:monify/pages/statistics/statistics_controller.dart';
import 'package:monify/pages/statistics/statistics_model.dart';
import 'package:provider/provider.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late final StatisticsController _controller;
  late final StatisticsModel _model;

  //init state
  @override
  void initState() {
    super.initState();
    _model = StatisticsModel();
    _controller = StatisticsController(_model);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: ((context) => _model),
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

class Chart extends StatelessWidget {
  const Chart(
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
          future: controller.calculateIncomeChartData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return DChartPie(
                data: snapshot.data!,
                fillColor: (pieData, index) {
                  switch (pieData['domain']) {
                    case 'Flutter':
                      return Colors.blue;
                    case 'React Native':
                      return Colors.blueAccent;
                    case 'Ionic':
                      return Colors.lightBlue;
                    default:
                      return kPrimaryColor;
                  }
                },
                pieLabel: (pieData, index) {
                  return "${pieData['domain']}:\n${pieData['measure']}%";
                },
                labelPosition: PieLabelPosition.auto,
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
              print(snapshot.data);
              return DChartPie(
                data: snapshot.data!,
                fillColor: (pieData, index) {
                  switch (pieData['domain']) {
                    case 'Flutter':
                      return Colors.blue;
                    case 'React Native':
                      return Colors.blueAccent;
                    case 'Ionic':
                      return Colors.lightBlue;
                    default:
                      return kPrimaryColor;
                  }
                },
                pieLabel: (pieData, index) {
                  return "${pieData['domain']}:\n${pieData['measure']}%";
                },
                labelPosition: PieLabelPosition.auto,
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
