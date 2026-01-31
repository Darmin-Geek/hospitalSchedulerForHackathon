import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_state.dart';

class SubmitTasksPage extends StatefulWidget {
  const SubmitTasksPage({super.key});

  @override
  State<SubmitTasksPage> createState() => _SubmitTasksPageState();
}

class _SubmitTasksPageState extends State<SubmitTasksPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _numberOfTimesController = TextEditingController();
  final _minSeparationController = TextEditingController();
  final _maxSeparationController = TextEditingController();
  
  Patient? _selectedPatient;
  TimeOfDay? _earliestStartTime;

  @override
  void dispose() {
    _nameController.dispose();

    _numberOfTimesController.dispose();
    _minSeparationController.dispose();
    _maxSeparationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _earliestStartTime ?? const TimeOfDay(hour: 0, minute: 0),
    );
    if (picked != null && picked != _earliestStartTime) {
      setState(() {
        _earliestStartTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a patient')),
        );
        return;
      }
      if (_earliestStartTime == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an earliest start time')),
        );
        return;
      }

      final int earliestStartTimeMinutes = _earliestStartTime!.hour * 60 + _earliestStartTime!.minute;

      context.read<AppStateCubit>().addTask(
        _nameController.text,
        _selectedPatient!.id,
        int.parse(_numberOfTimesController.text),
        int.parse(_minSeparationController.text),
        int.parse(_maxSeparationController.text),
        earliestStartTimeMinutes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _numberOfTimesController.clear();
      _minSeparationController.clear();
      _maxSeparationController.clear();
      setState(() {
        _selectedPatient = null;
        _earliestStartTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),

              BlocBuilder<AppStateCubit, AppState>(
                builder: (context, state) {
                  return DropdownButtonFormField<Patient>(
                    decoration: const InputDecoration(labelText: 'Patient'),
                    value: _selectedPatient,
                    items: state.patients.map((Patient patient) {
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
                    validator: (value) => value == null ? 'Please select a patient' : null,
                  );
                },
              ),
              TextFormField(
                controller: _numberOfTimesController,
                decoration: const InputDecoration(labelText: 'Number of Times'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of times';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minSeparationController,
                decoration: const InputDecoration(labelText: 'Minimum Separation (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimum separation';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _maxSeparationController,
                decoration: const InputDecoration(labelText: 'Maximum Separation (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum separation';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_earliestStartTime == null
                    ? 'Select Earliest Start Time'
                    : 'Earliest Start Time: ${_earliestStartTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
