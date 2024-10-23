import 'package:habitreminder/model/MHabit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class HabitCubit extends HydratedCubit<List<MHabit>> {
  HabitCubit() : super([]);

  // Add a new habit
  void addHabit(MHabit habit) {
    final updatedHabits = List<MHabit>.from(state)..add(habit);
    emit(updatedHabits);
    print("Current habits: ${updatedHabits.map((h) => h.todo).toList()}");
  }

  void removeHabit(String id) {
    final updatedHabits = List<MHabit>.from(state);
    updatedHabits.removeWhere((habit) => habit.id == id);
    emit(updatedHabits);
  }

  void updateHabit(String id, MHabit updatedHabit) {
    int habitIndex = state.indexWhere((habit) => habit.id == id);

    if (habitIndex != -1) {
      state[habitIndex] = updatedHabit;
      emit(List.from(state)); 
    } else {
      print("Habit with id $id not found");
    }
  }

  void updateStatus(String id, String date, bool complete) {
    final updatedHabits = List<MHabit>.from(state);
    final habitIndex = updatedHabits.indexWhere((habit) => habit.id == id);

    if (habitIndex != -1) {
      updatedHabits[habitIndex]
          .status
          .add({'date': date, 'complete': complete});
      emit(updatedHabits);
    } else {
      print("Habit with id $id not found.");
    }
  }

  @override
  List<MHabit>? fromJson(Map<String, dynamic> json) {
    print("Loading habits from JSON: $json");
    return (json['habits'] as List)
        .map((habit) => MHabit.fromJson(habit))
        .toList();
  }

  @override
  Map<String, dynamic>? toJson(List<MHabit> state) {
    final json = {
      'habits': state.map((habit) => habit.toJson()).toList(),
    };
    print("Saving habits to JSON: $json");
    return json;
  }
}
