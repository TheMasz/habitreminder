class MHabit {
  String id;
  String freq;
  String todo;
  String time;
  List<Map<String, dynamic>> status;
  List<String>? specific;

  MHabit({
    required this.id,
    required this.freq,
    required this.todo,
    required this.time,
    required this.status,
    this.specific,
  });

  // Convert the Habit object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'freq': freq,
      'todo': todo,
      'time': time,
      'status': status,
      'specific': specific,
    };
  }

  // Create a Habit object from JSON
  factory MHabit.fromJson(Map<String, dynamic> json) {
    return MHabit(
      id: json['id'],
      freq: json['freq'],
      todo: json['todo'],
      time: json['time'],
      status: List<Map<String, dynamic>>.from(json['status']),
      specific: json['specific'] != null
          ? List<String>.from(json['specific']) 
          : null,
    );
  }
}
