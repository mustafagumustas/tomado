import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PomodoroTimerScreen(),
    );
  }
}

class PomodoroTimerScreen extends StatefulWidget {
  @override
  _PomodoroTimerScreenState createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  int workDuration = 25; // in minutes
  int breakDuration = 5; // in minutes
  int timeLeft = 25 * 60; // in seconds
  bool isRunning = false;
  bool isWorking = true;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    double progress = 1.0 - (timeLeft / (isWorking ? workDuration : breakDuration * 60));

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(120, 120),
              painter: ProgressPainter(
                (isWorking ? timeLeft : breakDuration * 60).toDouble() / (isWorking ? workDuration * 60 : breakDuration * 60),
              ),
            ),
            SizedBox(height: 20),
            Text(
              formatTime(timeLeft),
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? null : () => updateWorkDurationDialog(),
                  child: Text('Set Work'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isRunning ? null : () => updateBreakDurationDialog(),
                  child: Text('Set Break'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startTimer();
                  },
                  child: Text('Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    stopTimer();
                  },
                  child: Text('Stop'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    resetTimer();
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          // Timer is completed, switch between Work and Break modes
          if (isWorking) {
            timeLeft = breakDuration * 60;
          } else {
            timeLeft = workDuration * 60;
          }
          isWorking = !isWorking;
        }
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      stopTimer();
      isWorking = true;
      timeLeft = workDuration * 60;
    });
  }

  void updateWorkDurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Work Duration'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                workDuration = int.tryParse(value) ?? workDuration;
                if (isWorking) {
                  timeLeft = workDuration * 60;
                }
              });
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void updateBreakDurationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Break Duration'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                breakDuration = int.tryParse(value) ?? breakDuration;
                if (!isWorking) {
                  timeLeft = breakDuration * 60;
                }
              });
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;

  ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
void updateWorkDurationDialog() {}

void updateBreakDurationDialog() {}
