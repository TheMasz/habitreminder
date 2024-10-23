import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitreminder/bloc/habit_cubit.dart';
import 'package:habitreminder/config/theme/app_colors.dart';
import 'package:habitreminder/model/MHabit.dart';
import 'package:habitreminder/screens/create_habit.dart';
import 'package:habitreminder/screens/dashboard.dart';
import 'package:habitreminder/screens/home.dart';
import 'package:habitreminder/screens/m_clipper.dart';
import 'package:habitreminder/screens/setting.dart';
import 'package:habitreminder/screens/update_habit.dart';

class Lists extends StatelessWidget {
  const Lists({super.key});

  void deleteHabit(BuildContext context, String id) {
    context.read<HabitCubit>().removeHabit(id);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "กิจกรรมทั้งหมด",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Expanded(
                    child: BlocBuilder<HabitCubit, List<MHabit>>(
                        builder: (context, habits) {
                      if (habits.isEmpty) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "(;-;)",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 48),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "คุณยังไม่มีกิจกรรม ไปเพิ่มเลย!",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      List<Widget> everyDayHabitWidgets = [];
                      List<Widget> everyWeekHabitWidgets = [];
                      List<Widget> everyMonthHabitWidgets = [];
                      List<Widget> specificHabitWidgets = [];

                      for (var habit in habits) {
                        if (habit.freq == 'ทุกวัน') {
                          everyDayHabitWidgets.add(_todo(context, habit));
                        } else if (habit.freq == 'ทุกอาทิตย์') {
                          everyWeekHabitWidgets.add(_todo(context, habit));
                        } else if (habit.freq == 'ทุกเดือน') {
                          everyMonthHabitWidgets.add(_todo(context, habit));
                        } else if (habit.freq == 'กำหนดเอง') {
                          specificHabitWidgets.add(_todo(context, habit));
                        }
                      }
                      return ListView(
                        children: [
                          if (everyDayHabitWidgets.isNotEmpty)
                            ExpansionTile(
                              title: const Text('ทุกวัน'),
                              children: everyDayHabitWidgets,
                            ),
                          if (everyWeekHabitWidgets.isNotEmpty)
                            ExpansionTile(
                              title: const Text('ทุกอาทิตย์'),
                              children: everyWeekHabitWidgets,
                            ),
                          if (everyMonthHabitWidgets.isNotEmpty)
                            ExpansionTile(
                              title: const Text('ทุกเดือน'),
                              children: everyMonthHabitWidgets,
                            ),
                          if (specificHabitWidgets.isNotEmpty)
                            ExpansionTile(
                              title: const Text('กำหนดเอง'),
                              children: specificHabitWidgets,
                            ),
                        ],
                      );
                    }),
                  ),
                ],
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

  Container _todo(BuildContext context, MHabit habit) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.todo,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "${habit.freq} => ${habit.time}น.",
                style: const TextStyle(
                    color: AppColors.yellowColor, fontWeight: FontWeight.w600),
              ),
              if (habit.freq == "กำหนดเอง")
                Text(
                  habit.specific!.join(' | '),
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.yellowColor,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateHabit(habit)),
                  );
                },
                child: Container(
                  height: 40,
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: AppColors.checkButton,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Icon(
                      Icons.build_circle_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  deleteHabit(context, habit.id);
                },
                child: Container(
                  height: 40,
                  width: 60,
                  decoration: BoxDecoration(
                      color: AppColors.cancelButton,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
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
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Lists()),
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
                    Icons.list,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
              icon: const Icon(Icons.dashboard),
              color: Colors.white,
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
