import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hospital_scheduler_frontend/app_state.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {

  TextEditingController nurseNameController = TextEditingController();
  TextEditingController patientNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column( mainAxisAlignment: MainAxisAlignment.spaceAround, 
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Nurses'),
            TextField(controller: nurseNameController),
            ElevatedButton(onPressed: () {
              context.read<AppStateCubit>().addNurse(nurseNameController.text);
              setState(() {});
            }, child: Text('Add Nurse')),
            Expanded(
              child: ListView.builder(
              itemCount: state.nurses.length,
              itemBuilder: (context, index) {
                return Card(child: Row( children: [Text(state.nurses.elementAt(index).name), IconButton(onPressed: () {
                  context.read<AppStateCubit>().removeNurse(state.nurses.elementAt(index));
                  setState(() {});
                }, icon: Text("X", style: TextStyle(color: Colors.red),))]));
              },
            ),),
            Text('Patients'),
            TextField(controller: patientNameController),
            ElevatedButton(onPressed: () {
              context.read<AppStateCubit>().addPatient(patientNameController.text);
              setState(() {});
            }, child: Text('Add Patient')),
            Expanded(
              child: ListView.builder(
              itemCount: state.patients.length,
              itemBuilder: (context, index) {
                return Card(child:  Row( children: [Text(state.patients.elementAt(index).name), IconButton(onPressed: () {
                  context.read<AppStateCubit>().removePatient(state.patients.elementAt(index));
                  setState(() {});
                }, icon: Text("X", style: TextStyle(color: Colors.red),))]));
              },
            ),),
          ],
        ),);
      },
    );
  }
}
