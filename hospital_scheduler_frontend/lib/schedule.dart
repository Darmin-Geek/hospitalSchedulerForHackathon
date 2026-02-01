import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hospital_scheduler_frontend/app_state.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Nurse? _selectedNurse;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, state) {
        // Initialize selected nurse if not set and nurses exist
        if (_selectedNurse == null && state.nurses.isNotEmpty) {
          _selectedNurse = state.nurses.first;
        } else if (_selectedNurse != null && !state.nurses.contains(_selectedNurse)) {
          // Reset if selected nurse was deleted
          _selectedNurse = state.nurses.isNotEmpty ? state.nurses.first : null;
        }

        List<Event> filteredEvents = [];
        if (_selectedNurse != null) {
          filteredEvents = state.events.where((e) {
            try {
              final task = state.tasks.firstWhere((t) => t.id == e.task_id);
              return task.activity_type == _selectedNurse!.activityType;
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
                _buildNurseDropdown(state.nurses.toList()),
                const SizedBox(height: 20),
                Expanded(
                  child: _selectedNurse == null
                      ? const Center(child: Text("Please select a nurse to view their schedule."))
                      : filteredEvents.isEmpty
                          ? const Center(child: Text("No events scheduled for this nurse."))
                          : ListView.builder(
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                final task = state.tasks.firstWhere((t) => t.id == event.task_id);
                                final patient = state.patients.firstWhere(
                                    (p) => p.id == task.patient_id,
                                    orElse: () => Patient(id: -1, name: 'Unknown Patient'));

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
                                    title: Text("${task.name} - ${patient.name}",
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(formattedTime),
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

  Widget _buildNurseDropdown(List<Nurse> nurses) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Select Nurse: ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<Nurse>(
          value: _selectedNurse,
          hint: const Text("Choose a Nurse"),
          items: nurses.map((Nurse nurse) {
            return DropdownMenuItem<Nurse>(
              value: nurse,
              child: Text("${nurse.name} - ${_getActivityName(nurse.activityType)}"),
            );
          }).toList(),
          onChanged: (Nurse? newValue) {
            setState(() {
              _selectedNurse = newValue;
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
