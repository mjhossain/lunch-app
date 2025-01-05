import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../screens/home_page.dart';
import '../theme/colors.dart';
import '../widgets/neumorphic_button.dart';
import '../models/lunch_note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _scaleController;
  Timer? _timer;
  int _duration = 15; // Start with minimum duration (15 minutes)
  int _remainingTime = 0;
  bool _isRunning = false;
  List<LunchNote> _topTasks = [];

  @override
  void initState() {
    super.initState();
    _remainingTime = _duration * 60;
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(minutes: _duration),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTopTasks();
  }

  Future<void> _loadTopTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('lunch_notes') ?? [];
    final allNotes = notesJson
        .map((noteStr) => LunchNote.fromJson(json.decode(noteStr)))
        .toList();
    setState(() {
      _topTasks = allNotes.take(3).toList(); // Get top 3 tasks
    });
  }

  void _adjustDuration(bool increase) {
    setState(() {
      if (increase && _duration < 120) { // Max 2 hours
        _duration += 5;
      } else if (!increase && _duration > 15) { // Min 15 minutes
        _duration -= 5;
      }
      if (!_isRunning) {
        _remainingTime = _duration * 60;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Timer duration adjustment
        if (!_isRunning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicButton(
                width: 48,
                height: 48,
                onPressed: () => _adjustDuration(false),
                child: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${_duration} min',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              NeumorphicButton(
                width: 48,
                height: 48,
                onPressed: () => _adjustDuration(true),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        const SizedBox(height: 40),
        // Timer display
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 300),
                    painter: TimerPainter(
                      animation: _timerController,
                      backgroundColor: AppColors.shadowColor,
                      color: AppColors.primaryColor,
                    ),
                  );
                },
              ),
              Text(
                _formatTime(_remainingTime),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Start/Stop button
        NeumorphicButton(
          width: 200,
          color: AppColors.primaryColor,
          onPressed: _toggleTimer,
          child: Text(
            _isRunning ? 'STOP' : 'START',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Top 3 tasks
        if (_topTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...List.generate(_topTasks.length, (index) {
                  final task = _topTasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.textColor),
                          ),
                          child: task.isCompleted
                              ? Icon(Icons.check, size: 16, color: AppColors.textColor)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.text,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _timerController.stop();
      setState(() => _isRunning = false);
    } else {
      _startTimer();
    }
  }

  // Format seconds into MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }


  // Show local notification with sound
  Future<void> _showNotification(String title, String body) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'lunch_timer_channel',
      'Lunch Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }


  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        if (_remainingTime == 0) {
          _remainingTime = _duration * 60;
        }
      });

      _timerController.duration = Duration(minutes: _duration);
      _timerController.forward(from: 1 - (_remainingTime / (_duration * 60)));

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _timerController.reset();
            _isRunning = false;
            _showNotification('Timer Complete!', 'Time to take a break.');
          }
        });
      });
    }
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);

    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}