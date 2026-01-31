import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class Nurse {
  int id;
  String name;
  int activityType;

  Nurse({required this.id, required this.name, required this.activityType});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'activityType': activityType,
      };

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'],
      name: json['name'],
      activityType: json['activityType'] ?? 5, // Default to 5 (Other) if null for compatibility
    );
  }
}

class Patient {
  int id;
  String name;

  Patient({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Task {
  int id;
  String name;

  int  activity_type;
  int duration;
  int patient_id;
  int number_of_times;
  int minimum_separation;
  int maximum_separation;
  int earliest_start_time;

  Task({
    required this.id,
    required this.name,
    required this.activity_type,
    required this.duration,
    required this.patient_id,
    required this.number_of_times,
    required this.minimum_separation,
    required this.maximum_separation,
    required this.earliest_start_time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'activity_type': activity_type,
        'duration': duration,
        'patient_id': patient_id,
        'number_of_times': number_of_times,
        'minimum_separation': minimum_separation,
        'maximum_separation': maximum_separation,
        'earliest_start_time': earliest_start_time,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      activity_type: json['activityType'] ?? 5, // Default to 5 (Other)
      duration: json['duration'] ?? 10, // Default to 10 minutes
      patient_id: json['patient_id'],
      number_of_times: json['number_of_times'],
      minimum_separation: json['minimum_separation'],
      maximum_separation: json['maximum_separation'],
      earliest_start_time: json['earliest_start_time'],
    );
  }
}

class Event {
  int task_id;
  double start_time;

  Event(
      {
      required this.task_id,
      required this.start_time});

  Map<String, dynamic> toJson() => {
        'task_id': task_id,
        'start_time': start_time,
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      task_id: json['task_id'],
      start_time: json['start_time'],
    );
  }
}

class AppState {
  Set<Nurse> nurses = {};
  Set<Patient> patients = {};
  Set<Task> tasks = {};
  Set<Event> events = {};

  int nurseNextId = 0;
  int patientNextId = 0;
  int taskNextId = 0;

  AppState();

  Map<String, dynamic> toJson() => {
        'nurses': nurses.map((n) => n.toJson()).toList(),
        'patients': patients.map((p) => p.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'nurseNextId': nurseNextId,
        'patientNextId': patientNextId,
        'taskNextId': taskNextId,
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    var state = AppState();
    state.nurses = (json['nurses'] as List).map((n) => Nurse.fromJson(n)).toSet();
    state.patients =
        (json['patients'] as List).map((p) => Patient.fromJson(p)).toSet();
    state.tasks = (json['tasks'] as List).map((t) => Task.fromJson(t)).toSet();
    state.events = (json['events'] as List).map((e) => Event.fromJson(e)).toSet();
    state.nurseNextId = json['nurseNextId'];
    state.patientNextId = json['patientNextId'];
    state.taskNextId = json['taskNextId'];
    return state;
  }
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState());

  void addNurse(String name, int activityType) {
    state.nurses.add(Nurse(id: state.nurseNextId, name: name, activityType: activityType));
    state.nurseNextId++;
    emit(state);
  }

  void addPatient(String name) {
    state.patients.add(Patient(id: state.patientNextId, name: name));
    state.patientNextId++;
    emit(state);
  }

  void addTask(String name, int activityType, int duration, int patientId, int numberOfTimes,
      int minimumSeparation, int maximumSeparation, int earliestStartTime) {
    state.tasks.add(Task(
        id: state.taskNextId,
        name: name,
        activity_type: activityType,
        duration: duration,
        patient_id: patientId,
        number_of_times: numberOfTimes,
        minimum_separation: minimumSeparation,
        maximum_separation: maximumSeparation,
        earliest_start_time: earliestStartTime));
    state.taskNextId++;
    emit(state);
    getUpdatedSchedule();
  }

  void getUpdatedSchedule() async {
    var response  = await http.post(Uri.parse('http://localhost:5000/schedule'), body: jsonEncode(state.toJson()), headers: {'Content-Type': 'application/json'});
    state.events = (jsonDecode(response.body) as List).map((e) => Event.fromJson(e)).toSet();
    emit(state);
  }

  void removeNurse(Nurse nurse) {
    state.nurses.remove(nurse);
    emit(state);
  }

  void removePatient(Patient patient) {
    state.patients.remove(patient);
    emit(state);
  }

  void removeTask(Task task) {
    state.tasks.remove(task);
    emit(state);
  }
}
