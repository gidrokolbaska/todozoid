import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Database/database.dart';
import '../controllers/navigation_bar_controller.dart';
import '../controllers/tasks_controller.dart';
import 'package:get/get.dart';
import '../helpers/time_extensions.dart';
import '../models/todo.dart';
import '../widgets/firestoreQueryBuilderNew.dart';
import '../consts/consts.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);
  final TasksController _tasksController = Get.put(TasksController());
  // final NavigationBarController navigationController =
  //     Get.put(NavigationBarController());
  final controller = PageController(viewportFraction: 1, keepPage: true);
  final DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      ActiveTasks(
        tasksController: _tasksController,
      ),
      TasksCompletedThisWeek(tasksController: _tasksController),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //TODAY'S DATE
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: TodaysDate(date: date),
        ),
        //DASHBOARD CARDS
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 26.60),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: pages.length,
                      effect: WormEffect(
                        dotHeight: 16,
                        dotWidth: 16,
                        type: WormType.thin,
                        activeDotColor: context.isDarkMode
                            ? Constants.kDarkThemeAccentColor
                            : Constants.kAccentColor,
                        dotColor: context.isDarkMode
                            ? Constants.kDarkThemeLightOnLightColor
                            : Constants.kWhiteBgColor,
                        // strokeWidth: 5,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    clipBehavior: Clip.none,
                    controller: controller,
                    // itemCount: pages.length,
                    itemBuilder: (_, index) {
                      return pages[index % pages.length];
                    },
                  ),
                ),
                //const SizedBox(height: 26.60),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TasksCompletedThisWeek extends StatelessWidget {
  const TasksCompletedThisWeek({
    Key? key,
    required TasksController tasksController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      //height: 215.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: context.isDarkMode
            ? Constants.kDarkThemeBGLightColor
            : Constants.kWhiteBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.1),
            blurRadius: 3.0,
            spreadRadius: 1.0,
            offset: const Offset(2.0, 2.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'thisweek'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                color: Get.isDarkMode
                    ? Constants.kDarkThemeTextColorAlternative
                    : Constants.kBlackTextOnWhiteBGColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            CompletedThisWeek(),
          ],
        ),
      ),
    );
  }
}

class CompletedThisWeek extends StatelessWidget {
  CompletedThisWeek({Key? key}) : super(key: key);
  final DatabaseController databaseController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FirestoreQueryBuilderNew<Todo>(
        query: databaseController.todosCollection,
        builder: (context, snapshot, child) {
          if (snapshot.isFetching) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }
          if (snapshot.hasMore) {
            snapshot.fetchMore();
          }
          return Text(
            '${snapshot.docs.where((element) => element.data().whenCompleted != null && element.data().whenCompleted!.toDate().isOnCurrentWeek(element.data().whenCompleted!.toDate(), context)).length}',
            style: TextStyle(
              fontSize: 75.sp,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode
                  ? Constants.kDarkThemeTextColorAlternative
                  : Constants.kAlternativeTextColor,
            ),
          );
        },
      ),
    );
  }
}
// class Chart extends StatelessWidget {
//   const Chart({
//     Key? key,
//     required TasksController tasksController,
//   })  : _tasksController = tasksController,
//         super(key: key);

//   final TasksController _tasksController;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: BarChart(
//         BarChartData(
//           backgroundColor: Colors.transparent,
//           gridData: FlGridData(
//             show: false,
//           ),

//           barTouchData: BarTouchData(
//             enabled: false,
//             touchTooltipData: BarTouchTooltipData(
//               tooltipBgColor: context.isDarkMode
//                   ? Constants.kDarkThemeBGLightColor
//                   : Constants.kWhiteBgColor,
//               tooltipPadding: const EdgeInsets.all(0),
//               tooltipMargin: 8,
//               getTooltipItem: (
//                 BarChartGroupData group,
//                 int groupIndex,
//                 BarChartRodData rod,
//                 int rodIndex,
//               ) {
//                 return BarTooltipItem(
//                   rod.toY.round().toString(),
//                   TextStyle(
//                     color: context.isDarkMode
//                         ? Constants.kDarkThemeTextColorAlternative
//                         : Constants.kBlackTextOnWhiteBGColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 );
//               },
//             ),
//           ),
//           alignment: BarChartAlignment.spaceBetween,
//           // minY: 1,
//           // maxY: 90,
//           titlesData: FlTitlesData(
//             show: true,
//             leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     _tasksController.getDayHeaders(
//                         MaterialLocalizations.of(context), value),
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: context.isDarkMode
//                           ? Constants.kDarkThemeTextColor
//                           : Constants.kBlackTextOnWhiteBGColor.withOpacity(0.6),
//                       fontWeight: FontWeight.normal,
//                       letterSpacing: 0.75,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           borderData: FlBorderData(
//             show: false,
//           ),
//           barGroups: [
//             BarChartGroupData(
//               x: 0,
//               barRods: [
//                 BarChartRodData(
//                   toY: 25,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 ),
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 1,
//               barRods: [
//                 BarChartRodData(
//                   toY: 10,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 2,
//               barRods: [
//                 BarChartRodData(
//                   toY: 14,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 3,
//               barRods: [
//                 BarChartRodData(
//                   toY: 15,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 4,
//               barRods: [
//                 BarChartRodData(
//                   toY: 13,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 5,
//               barRods: [
//                 BarChartRodData(
//                   toY: 10,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//             BarChartGroupData(
//               x: 6,
//               barRods: [
//                 BarChartRodData(
//                   toY: 5,
//                   color: context.isDarkMode
//                       ? Constants.kDarkThemeAccentColor
//                       : Constants.kAccentColor,
//                   width: 13,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(13),
//                     topRight: Radius.circular(13),
//                   ),
//                 )
//               ],
//               showingTooltipIndicators: [0],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ActiveTasks extends StatelessWidget {
  ActiveTasks({
    Key? key,
    required TasksController tasksController,
  })  : _tasksController = tasksController,
        super(key: key);

  final TasksController _tasksController;
  final NavigationBarController controller = Get.find();
  final DatabaseController databaseController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      //height: 315.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: context.isDarkMode
            ? Constants.kDarkThemeBGLightColor
            : Constants.kWhiteBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.1),
            blurRadius: 3.0,
            spreadRadius: 1.0,
            offset: const Offset(2.0, 2.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'activetasks'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode
                        ? Constants.kDarkThemeTextColorAlternative
                        : Constants.kBlackTextOnWhiteBGColor,
                  ),
                ),
                FirestoreQueryBuilderNew<Todo>(
                  query: databaseController.todosCollection
                      .where('isDone', isEqualTo: false),
                  builder: (context, snapshot, child) {
                    if (snapshot.isFetching) {
                      return const Center(
                          child: Center(
                              child: CircularProgressIndicator.adaptive()));
                    }

                    if (snapshot.hasError) {
                      return Text('Something went wrong! ${snapshot.error}');
                    }
                    if (snapshot.hasMore) {
                      snapshot.fetchMore();
                    }

                    return Text(
                      '${snapshot.docs.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 70.sp,
                        color: Get.isDarkMode
                            ? Constants.kDarkThemeTextColorAlternative
                            : Constants.kAlternativeTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Constants.kWhiteBgColor,
                    minimumSize: Size(100.w, 30.h),
                    //elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    controller.changePage(0);
                  },
                  child: Text(
                    'view'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      //color: Constants.kWhiteBgColor,
                      letterSpacing: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FirestoreQueryBuilderNew<Todo>(
              query: databaseController.todosCollection
                  .where('isDone', isEqualTo: true)
                  .where(
                    'whenCompleted',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ),
                  ),
              builder: (context, snapshot, child) {
                if (snapshot.isFetching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Something went wrong! ${snapshot.error}');
                }
                // return const Center(child: CircularProgressIndicator());
                return SleekCircularSlider(
                  innerWidget: (percentage) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('dailygoal'.tr),
                          Obx(
                            () => Text(
                              '${snapshot.docs.length}/${_tasksController.dailyGoal.value}',
                              style: TextStyle(
                                  fontSize: 19.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  appearance: CircularSliderAppearance(
                      animationEnabled: false,
                      infoProperties: InfoProperties(
                        mainLabelStyle: TextStyle(
                          fontSize: 19.sp,
                          color: Get.isDarkMode
                              ? Constants.kDarkThemeTextColorAlternative
                              : Constants.kBlackTextOnWhiteBGColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.75,
                        ),
                      ),
                      customColors: CustomSliderColors(
                        hideShadow: true,
                        trackColor: context.isDarkMode
                            ? Constants.kDarkThemeBGColor
                            : Constants.kGrayBgColor,
                        progressBarColor: context.isDarkMode
                            ? Constants.kDarkThemeAccentColor
                            : Constants.kAccentColor,
                      ),
                      size: 150.sp,
                      customWidths: CustomSliderWidths(
                          progressBarWidth: 12.0,
                          trackWidth: 12.0,
                          handlerSize: 0,
                          shadowWidth: 0)),
                  min: 0,
                  max: 100,
                  initialValue: _tasksController
                              .percentsCompleted(snapshot.docs.length) <=
                          100
                      ? _tasksController.percentsCompleted(snapshot.docs.length)
                      : 100,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysDate extends StatelessWidget {
  const TodaysDate({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(DateFormat('EEEE', Platform.localeName).format(date),
            style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold)),
        //Text(DateFormat('EEEE').format(date),

        const SizedBox(
          width: 16.0,
        ),
        Text(
          '${date.day}',
          style: TextStyle(fontSize: 35.sp),
        ),
      ],
    );
  }
}
