# Sleep Focused Hospital Scheduler

## Problem
This project is designed to help patients at capital region hospitals such as Troy's Samaritan Hospital. When nurses do rounds, they often wake up patients. This is especially true at night when patients are trying to sleep. While nurses must check on patients, they should do so in a way that minimizes the amount of sleep patients lose.

## Solution
This project schedules the nurses in a hospital. Its goal is to maximize pationt sleep, and thus improve patient outcomes. The scheduler's main advantage over a traditional rounds system is that it tries to align nurse schedules. Rather than a patient being woken up twice, under a schedule computed by this system, the patient would be woken up only once because both nurses enter the room at the same time.

This project includes a backend and a frontend. The backend is written in Python and uses Google's OR-Tools to solve the scheduling problem. The frontend is a windows application written in Flutter and provides a user interface for inputting tasks into the scheduler and viewing the solution.

## How to run

### Requirements
* Python >=3.13
* [Flutter](https://flutter.dev/) >=3.38
* Visual Studio 2022 with Desktop development with C++ workload installed

### Backend

Create venv and then install the dependencies with
```bash
pip install -r requirements.txt
```

Run the server
```bash
flask run
```

### Frontend

Get dependencies
```bash
flutter pub get
```
Run the frontend
```bash
flutter run
```

### File structure
```
backend/          # Python backend
  app.py          # Main Flask application
  requirements.txt  # Python dependencies
hospital_scheduler_frontend/         # Flutter frontend
  lib/            # Flutter application code
  pubspec.yaml    # Flutter dependencies
```
Please note: while it is possible to run the backend on a separate machine from the frontend, the system is configured for running on a single machine. The backend is heavily optimized so it can run on a nonpowerful laptop. The original algorithm I implemented on the morning of the hackathon used 12 GB of memory but I optimized it to use less than ~50 MB of memory.
