import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitreminder/config/theme/app_colors.dart';
import 'package:habitreminder/bloc/theme_cubit.dart';
import 'package:habitreminder/screens/create_habit.dart';
import 'package:habitreminder/screens/dashboard.dart';
import 'package:habitreminder/screens/home.dart';
import 'package:habitreminder/screens/lists.dart';
import 'package:habitreminder/screens/m_clipper.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBar(),
          Container(
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
                Text(
                  "ตั้งค่า",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "โหมดกลางคืน",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) {
                        return Switch(
                          value: mode == ThemeMode.dark,
                          onChanged: (value) {
                            context.read<ThemeCubit>().updateTheme(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
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
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
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
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
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
