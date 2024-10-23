import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitreminder/bloc/habit_cubit.dart';
import 'package:habitreminder/config/theme/app_colors.dart';
import 'package:habitreminder/model/MHabit.dart';
import 'package:habitreminder/screens/create_habit.dart';
import 'package:habitreminder/screens/home.dart';
import 'package:habitreminder/screens/lists.dart';
import 'package:habitreminder/screens/m_clipper.dart';
import 'package:habitreminder/screens/setting.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isBoxVisible = false;
  Map<String, bool> isExpanded = {
    "ทุกวัน": false,
    "ทุกอาทิตย์": false,
    "ทุกเดือน": false,
    "กำหนดเอง": false,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "สรุปผล",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlocBuilder<HabitCubit, List<MHabit>>(
                      builder: (context, habits) {
                        // Map<String, List<MHabit>> habitsByFrequency = {};
                        Map<String, List<MHabit>> habitsByFrequency = {
                          "ทุกวัน": [],
                          "ทุกอาทิตย์": [],
                          "ทุกเดือน": [],
                          "กำหนดเอง": [],
                        };
                        for (var habit in habits) {
                          if (!habitsByFrequency.containsKey(habit.freq)) {
                            habitsByFrequency[habit.freq] = [];
                          }
                          habitsByFrequency[habit.freq]!.add(habit);
                        }

                        List<Widget> habitWidgets = [];
                        habitsByFrequency.forEach((freq, habitList) {
                          habitWidgets.add(
                            AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xff1E1E1E)
                                    : Colors.white,
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(8),
                              duration: const Duration(milliseconds: 500),
                              width: double.infinity,
                              height: isExpanded[freq]! ? null : 150,
                              constraints: isExpanded[freq]!
                                  ? BoxConstraints(
                                      minHeight: 150,
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                    )
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  habitList.isEmpty
                                      ? Column(
                                          children: [
                                            Text(
                                              "ความสำเร็จประจำ$freq",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: AppColors.yellowColor,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "คุณยังไม่มีกิจกรรม ไปเพิ่มเลย!",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        )
                                      : Expanded(
                                          child: SingleChildScrollView(
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 80,
                                                  width: 80,
                                                  child: Image.asset(
                                                      "assets/images/reward.png"),
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      "ความสำเร็จประจำ$freq",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 22,
                                                        color: AppColors
                                                            .yellowColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    for (var habit in habitList)
                                                      _habit(habit)
                                                  ],
                                                ),
                                              ]),
                                        )),
                                  if (habitList.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isExpanded[freq] = !isExpanded[freq]!;
                                        });
                                      },
                                      child: Text(isExpanded[freq]!
                                          ? "ซ่อน"
                                          : "ดูทั้งหมด"),
                                    ),
                                ],
                              ),
                            ),
                          );
                        });

                        return Column(
                          children: habitWidgets,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateHabit()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.yellowColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: _bottomAppBar(context),
    );
  }

  Column _habit(MHabit habit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• ${habit.todo}",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "• ทำติดต่อกันเป็นระยะเวลา ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                text:
                    habit.status.isEmpty ? "0" : habit.status.length.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " วัน",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
      ],
    );
  }

  Stack _headerBar() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: MClipper(),
          child: Container(
            height: 150.0,
            decoration: const BoxDecoration(
              color: Color(0xff6C5CE7),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/avatar.jpg"),
                          radius: 20,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications),
                            color: AppColors.yellowColor)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BottomAppBar _bottomAppBar(BuildContext context) {
    return BottomAppBar(
      height: 100,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff6C5CE7),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              icon: const Icon(Icons.home),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lists()),
                );
              },
              icon: const Icon(Icons.list),
              color: Colors.white,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff8F81F9),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
                );
              },
              icon: const Icon(Icons.settings),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
