import 'package:flutter/material.dart';
import 'package:habitreminder/bloc/habit_cubit.dart';
import 'package:habitreminder/config/theme/app_colors.dart';
import 'package:habitreminder/model/MHabit.dart';
import 'package:habitreminder/screens/create_habit.dart';
import 'package:habitreminder/screens/dashboard.dart';
import 'package:habitreminder/screens/home.dart';
import 'package:habitreminder/screens/lists.dart';
import 'package:habitreminder/screens/m_clipper.dart';
import 'package:habitreminder/screens/setting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateHabit extends StatefulWidget {
  final MHabit habit;

  const UpdateHabit(this.habit, {Key? key}) : super(key: key);

  @override
  State<UpdateHabit> createState() => _UpdateHabitState();
}

class _UpdateHabitState extends State<UpdateHabit> {
  String? _fqValue;
  TimeOfDay? _timeValue;
  List<String> selectedDays = [];

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _hobitValue = TextEditingController();

  final List<String> _fqList = [
    'ทุกวัน',
    'ทุกอาทิตย์',
    'ทุกเดือน',
    'กำหนดเอง',
  ];

  @override
  void initState() {
    super.initState();

    _hobitValue.text = widget.habit.todo;
    _fqValue = widget.habit.freq;
    _timeController.text = widget.habit.time;

    if (widget.habit.specific != null) {
      selectedDays = List<String>.from(widget.habit.specific!);
    }
  }

  bool isSelected(String day) {
    return selectedDays.contains(day);
  }

  void toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeValue ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _timeValue) {
      setState(() {
        _timeValue = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void submitHabit(BuildContext context) {
    final formattedTime = formatTimeOfDay(_timeValue!);
    final updatedHabit = MHabit(
      id: widget.habit.id,
      freq: _fqValue!,
      todo: _hobitValue.text,
      time: formattedTime,
      status: widget.habit.status,
      specific: selectedDays.isNotEmpty ? selectedDays : null,
    );

    context.read<HabitCubit>().updateHabit(widget.habit.id, updatedHabit);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBar(),
          _updateHabitForms(context),
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

  Container _updateHabitForms(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "แก้ไขกิจกรรม",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: _hobitValue,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(15),
              hintText: "ชื่อกิจกรรม",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: AbsorbPointer(
              child: SizedBox(
                height: 57,
                child: TextField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15),
                    hintText: "เวลา",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.lightBackground
                            : AppColors.darkBackground,
                        width: 2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.lightBackground
                            : AppColors.darkBackground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButton(
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                _fqValue != null && _fqValue!.isNotEmpty
                    ? _fqValue!
                    : "เลือกความถี่",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            underline: Container(
              height: 2,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.lightBackground
                  : AppColors.darkBackground,
            ),
            items: _fqList.map((String fq) {
              return DropdownMenuItem<String>(
                value: fq,
                child: Text(fq),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _fqValue = newValue;
              });
            },
          ),
          if (_fqValue == "กำหนดเอง") ...[
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(context, "อา."),
                _circleButton(context, "จ."),
                _circleButton(context, "อ."),
                _circleButton(context, "พ."),
                _circleButton(context, "พฤ."),
                _circleButton(context, "ศ."),
                _circleButton(context, "ส."),
              ],
            ),
          ],
          const SizedBox(
            height: 40,
          ),
          GestureDetector(
            onTap: () {
              submitHabit(context);
            },
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.yellowColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "บันทึก",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _circleButton(BuildContext context, String day) {
    return GestureDetector(
      onTap: () {
        toggleDay(day);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected(day)
              ? AppColors.primary
              : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: isSelected(day) ? Colors.white : null,
            ),
          ),
        ),
      ),
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
}
