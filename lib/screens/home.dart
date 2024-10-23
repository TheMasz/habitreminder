import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitreminder/bloc/habit_cubit.dart';
import 'package:habitreminder/config/assets/noti.dart';
import 'package:habitreminder/config/theme/app_colors.dart';
import 'package:habitreminder/model/MHabit.dart';
import 'package:habitreminder/screens/create_habit.dart';
import 'package:habitreminder/screens/dashboard.dart';
import 'package:habitreminder/screens/lists.dart';
import 'package:habitreminder/screens/m_clipper.dart';
import 'package:habitreminder/screens/setting.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  String formatDate(DateTime date) {
    return DateFormat('d/M/y').format(date);
  }

  void scheduledNotification(DateTime habitTime, MHabit habit) {
    Noti.scheduleNotification(
      id: habit.id.hashCode,
      title: "Habit Reminder",
      body: "🎉 ถึงเวลาลุย! มาทำ: ${habit.todo} กันเลย 💪",
      scheduledTime: habitTime,
    );
  }

  void _showAlertDialog(BuildContext context, MHabit habit) {
    DateTime now = DateTime.now();
    final timeParts = habit.time.split(":");
    final habitHour = int.parse(timeParts[0]);
    final habitMinute = int.parse(timeParts[1]);
    final habitTime =
        DateTime(now.year, now.month, now.day, habitHour, habitMinute);
    String currentDay = formatDate(now);

    if (now.isBefore(habitTime)) {
      print("not time to success");
      return;
    }

    audioPlayer.play(AssetSource('sounds/assignment.mp3'));

    context.read<HabitCubit>().updateStatus(habit.id, currentDay, true);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[400],
                size: 60,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("🎉 เยี่ยมมาก!"),
              const SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: "คุณทำ "),
                    TextSpan(
                      text: habit.todo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: " สำเร็จแล้ว!"),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("💪✨ เก่งสุดๆ ไปเลย!")
            ],
          ),
        ));
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    });
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
                    "กิจกรรมประจำวัน",
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

                        List<Widget> habitWidgets = [];

                        for (var habit in habits) {
                          final now = DateTime.now();
                          final currentDay = formatDate(now);

                          final timeParts = habit.time.split(":");
                          final habitHour = int.parse(timeParts[0]);
                          final habitMinute = int.parse(timeParts[1]);
                          final habitTime = DateTime(now.year, now.month,
                              now.day, habitHour, habitMinute);
                          bool isHabitCompletedToday = habit.status
                              .any((map) => map['date'] == currentDay);

                          if (!isHabitCompletedToday) {
                            if (habit.freq == "ทุกวัน") {
                              habitWidgets.add(_todo(context, habit));
                              if (habitTime.isAfter(now)) {
                                scheduledNotification(habitTime, habit);
                              }
                            } else if (habit.freq == "ทุกอาทิตย์") {
                              String currentDayOfWeek =
                                  DateFormat('E', 'th').format(now);
                              if (currentDayOfWeek == "อา.") {
                                habitWidgets.add(_todo(context, habit));
                                if (habitTime.isAfter(now)) {
                                  scheduledNotification(habitTime, habit);
                                }
                              }
                            } else if (habit.freq == "ทุกเดือน") {
                              int dayOfMonth = now.day;
                              int lastDayOfMonth =
                                  DateTime(now.year, now.month + 1, 0).day;
                              if (dayOfMonth == 1 ||
                                  dayOfMonth == lastDayOfMonth) {
                                habitWidgets.add(_todo(context, habit));
                                if (habitTime.isAfter(now)) {
                                  scheduledNotification(habitTime, habit);
                                }
                              }
                            } else if (habit.freq == "กำหนดเอง") {
                              String currentDay =
                                  DateFormat('E', 'th').format(now);
                              if (habit.specific != null &&
                                  habit.specific!.contains(currentDay)) {
                                habitWidgets.add(_todo(context, habit));
                                if (habitTime.isAfter(now)) {
                                  scheduledNotification(habitTime, habit);
                                }
                              }
                            }
                          }
                        }

                        if (habitWidgets.isEmpty) {
                          return const Center(
                            child: Text("วันนี้คุณว่าง"),
                          );
                        }

                        return ListView(children: habitWidgets);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
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
          GestureDetector(
            onTap: () {
              _showAlertDialog(context, habit);
            },
            child: Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                  color: AppColors.checkButton,
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
              ),
            ),
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
            height: 300.0,
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
                          color: AppColors.yellowColor,
                        )
                      ],
                    ),
                  ),
                  const Text(
                    'สวัสดี,',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'มาสร้างนิสัยดีๆ ไปด้วยกัน!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xff8F81F9),
                  ),
                  child: const Icon(Icons.home, color: Colors.white),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Lists()),
                  );
                },
                icon: const Icon(
                  Icons.list,
                ),
                color: Colors.white),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
                icon: const Icon(
                  Icons.dashboard,
                ),
                color: Colors.white),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                },
                icon: const Icon(Icons.settings),
                color: Colors.white),
          ],
        ),
      ),
    );
  }
}

