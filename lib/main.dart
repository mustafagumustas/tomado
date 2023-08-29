import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  PomodoroTimer _timer = PomodoroTimer(3);

  void _updateUI() {
    setState(() {});
  }
  Widget _buildCircularProgress() {
    double progress = 1 - (_timer.remainingTime / _timer.initialTime);
    int minutes = _timer.remainingTime ~/ 60;
    int seconds = _timer.remainingTime % 60;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Text(
          '$minutes:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session History:'),
        for (int sessionTime in _timer.history)
          Text('$sessionTime seconds'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _buildCircularProgress(),
            SizedBox(height: 20), // Adding vertical space
            //Text('${_timer.remainingTime ~/ 60}:${_timer.remainingTime % 60}'),
            ElevatedButton(
              onPressed: () {
                if (!_timer.isRunning) {
                  _timer.startTimer(_updateUI);
                } else {
                  _timer.pauseTimer();
                }
              },
              child: Text(_timer.isRunning ? 'Pause' : 'Start'),
            ),
            ElevatedButton(
              onPressed: () {
                _timer.resetTimer();
                _updateUI();
              },
              child: Text('Reset'),
            ),
            SizedBox(height: 20), // Adding vertical space
            _buildHistoryList(), // Display Pomodoro session history
          ],
        ),
      ),
    );
  }
}


class PomodoroTimer {
  int initialTime;
  int remainingTime = 0; // Initialize to 0
  bool isRunning = false;

  PomodoroTimer(this.initialTime) {
    resetTimer();
  }

  void startTimer(VoidCallback updateUI) {
    if (!isRunning) {
      isRunning = true;
      _tick(updateUI);
    }
  }

  List<int> history = []; // List to store completed Pomodoro session times

  void _tick(VoidCallback updateUI) {
    Future.delayed(Duration(seconds: 1), () {
      if (isRunning && remainingTime > 0) {
        remainingTime--;
        updateUI();
        _tick(updateUI);
      } else {
        isRunning = false;
        if (remainingTime == 0) {
          history.add(initialTime);
        }
        updateUI();
      }
    });
  }

  void pauseTimer() {
    isRunning = false;
  }

  void resetTimer() {
    isRunning = false;
    remainingTime = initialTime;
  }
}
