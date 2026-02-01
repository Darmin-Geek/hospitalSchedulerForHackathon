import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hospital_scheduler_frontend/app_state.dart';

class PatientSchedulePage extends StatefulWidget {
  const PatientSchedulePage({super.key});

  @override
  State<PatientSchedulePage> createState() => _PatientSchedulePageState();
}

class _PatientSchedulePageState extends State<PatientSchedulePage> {
  Patient? _selectedPatient;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, state) {
        // Initialize selected patient if not set and patients exist
        if (_selectedPatient == null && state.patients.isNotEmpty) {
          _selectedPatient = state.patients.first;
        } else if (_selectedPatient != null && !state.patients.contains(_selectedPatient)) {
          // Reset if selected patient was deleted
          _selectedPatient = state.patients.isNotEmpty ? state.patients.first : null;
        }

        List<Event> filteredEvents = [];
        if (_selectedPatient != null) {
          filteredEvents = state.events.where((e) {
            try {
              final task = state.tasks.firstWhere((t) => t.id == e.task_id);
              return task.patient_id == _selectedPatient!.id;
            } catch (_) {
              return false;
            }
          }).toList();

          filteredEvents.sort((a, b) => a.start_time.compareTo(b.start_time));
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildPatientDropdown(state.patients.toList()),
                const SizedBox(height: 20),
                Expanded(
                  child: _selectedPatient == null
                      ? const Center(child: Text("Please select a patient to view their schedule."))
                      : filteredEvents.isEmpty
                          ? const Center(child: Text("No events scheduled for this patient."))
                          : ListView.builder(
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                final task = state.tasks.firstWhere((t) => t.id == event.task_id);

                                final int startMinutes = event.start_time.round();
                                final int endMinutes = startMinutes + task.duration;
                                final String formattedTime =
                                    "${_formatTime(startMinutes)} - ${_formatTime(endMinutes)}";

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getActivityColor(task.activity_type),
                                      child: Text(
                                        task.activity_type.toString(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(task.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("$formattedTime\n${_getActivityName(task.activity_type)}"),
                                    isThreeLine: true,
                                    trailing: Text("${task.duration} min"),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientDropdown(List<Patient> patients) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Patient: ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<Patient>(
          value: _selectedPatient,
          hint: const Text("Choose a Patient"),
          items: patients.map((Patient patient) {
            return DropdownMenuItem<Patient>(
              value: patient,
              child: Text(patient.name),
            );
          }).toList(),
          onChanged: (Patient? newValue) {
            setState(() {
              _selectedPatient = newValue;
            });
          },
        ),
      ],
    );
  }

  String _formatTime(int minutesFromMidnight) {
    int hour = minutesFromMidnight ~/ 60;
    int minute = minutesFromMidnight % 60;
    String period = "AM";
    
    if (hour >= 12) {
      period = "PM";
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;

    return "$hour:${minute.toString().padLeft(2, '0')} $period";
  }

  String _getActivityName(int type) {
    switch (type) {
      case 1:
        return "Blood Pressure/Pulse";
      case 2:
        return "Medicine Cart A";
      case 3:
        return "Medicine Cart B";
      case 4:
        return "Change IV Bag";
      default:
        return "Other";
    }
  }

  Color _getActivityColor(int type) {
    switch (type) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
