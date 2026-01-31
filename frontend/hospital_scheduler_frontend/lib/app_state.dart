
import 'package:flutter_bloc/flutter_bloc.dart';

class Nurse {
  int id;
  String name;

  Nurse({required this.id, required this.name});
}

class Patient {
  int id;
  String name;

  Patient({required this.id, required this.name});
}

class Task {
  int id;
  String name;
  int duration;
  int patient_id;
  int number_of_times;
  int minimum_separation;
  int maximum_separation;
  int earliest_start_time;

  Task({
    required this.id,
    required this.name,
    required this.duration,
    required this.patient_id,
    required this.number_of_times,
    required this.minimum_separation,
    required this.maximum_separation,
    required this.earliest_start_time,
  });
}
class AppState {
  Set<Nurse> nurses = {}; 
  Set<Patient> patients = {};
  Set<Task> tasks = {};

  int nurseNextId = 0;
  int patientNextId = 0;
  int taskNextId = 0;
}
class AppStateCubit extends Cubit<AppState> {
 

  AppStateCubit()  : super(AppState());

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

  void addTask(String name, int duration, int patientId, int numberOfTimes, int minimumSeparation, int maximumSeparation, int earliestStartTime) {
    state.tasks.add(Task(id: state.taskNextId, name: name, duration: duration, patient_id: patientId, number_of_times: numberOfTimes, minimum_separation: minimumSeparation, maximum_separation: maximumSeparation, earliest_start_time: earliestStartTime));
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