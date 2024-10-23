import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitreminder/bloc/habit_cubit.dart';
import 'package:habitreminder/config/assets/noti.dart';
import 'package:habitreminder/config/theme/app_theme.dart';
import 'package:habitreminder/bloc/theme_cubit.dart';
import 'package:habitreminder/screens/home.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  

  await initializeDateFormatting('th_TH', null);
  tz.initializeTimeZones();
  final location = tz.getLocation('Asia/Bangkok');
  tz.setLocalLocation(location);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await Noti.initialize(flutterLocalNotificationsPlugin);

  runApp(const HobitApp());
}

class HobitApp extends StatelessWidget {
  const HobitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HabitCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: const Home(),
        ),
      ),
    );
  }
}
