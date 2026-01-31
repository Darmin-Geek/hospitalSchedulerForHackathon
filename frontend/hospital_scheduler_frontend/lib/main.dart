import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hospital_scheduler_frontend/app_state.dart';
import 'package:hospital_scheduler_frontend/setup_page';
import 'package:hospital_scheduler_frontend/submit_tasks_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Hospital Scheduler'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Setup'),
                Tab(text: 'Submit Tasks'),
                Tab(text: 'View Schedule'),
              ],
            ),
          ),
          body: BlocProvider(
            create: (_) => AppStateCubit(),
            child: Center(
              child: TabBarView(children: [
                SetupPage(),
                SubmitTasksPage(),
                Text('Hello WorldC!'),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
