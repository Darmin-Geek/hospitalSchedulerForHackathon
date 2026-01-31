import 'package:flutter_bloc/flutter_bloc.dart';

class Nurse {
  int id;
  String name;

  Nurse({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'],
      name: json['name'],
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

  int patient_id;
  int number_of_times;
  int minimum_separation;
  int maximum_separation;
  int earliest_start_time;

  Task({
    required this.id,
    required this.name,
    required this.patient_id,
    required this.number_of_times,
    required this.minimum_separation,
    required this.maximum_separation,
    required this.earliest_start_time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
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
      patient_id: json['patient_id'],
      number_of_times: json['number_of_times'],
      minimum_separation: json['minimum_separation'],
      maximum_separation: json['maximum_separation'],
      earliest_start_time: json['earliest_start_time'],
    );
  }
}

class Event {
  int patient_id;
  int nurse_id;
  int task_id;
  int start_time;

  Event(
      {required this.patient_id,
      required this.nurse_id,
      required this.task_id,
      required this.start_time});

  Map<String, dynamic> toJson() => {
        'patient_id': patient_id,
        'nurse_id': nurse_id,
        'task_id': task_id,
        'start_time': start_time,
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      patient_id: json['patient_id'],
      nurse_id: json['nurse_id'],
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

  void addNurse(String name) {
    state.nurses.add(Nurse(id: state.nurseNextId, name: name));
    state.nurseNextId++;
    emit(state);
  }

  void addPatient(String name) {
    state.patients.add(Patient(id: state.patientNextId, name: name));
    state.patientNextId++;
    emit(state);
  }

  void addTask(String name, int patientId, int numberOfTimes,
      int minimumSeparation, int maximumSeparation, int earliestStartTime) {
    state.tasks.add(Task(
        id: state.taskNextId,
        name: name,
        patient_id: patientId,
        number_of_times: numberOfTimes,
        minimum_separation: minimumSeparation,
        maximum_separation: maximumSeparation,
        earliest_start_time: earliestStartTime));
    state.taskNextId++;
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
