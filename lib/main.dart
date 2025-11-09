import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';
import 'screens/log_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(const PianoPracticeTrackerApp());
}

class PianoPracticeTrackerApp extends StatelessWidget {
  const PianoPracticeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Practice Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<LogScreenState> _logScreenKey = GlobalKey<LogScreenState>();
  final GlobalKey<ProgressScreenState> _progressScreenKey =
      GlobalKey<ProgressScreenState>();
  final GlobalKey<CalendarScreenState> _calendarScreenKey =
      GlobalKey<CalendarScreenState>();

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Refresh screens when switching to them
    switch (index) {
      case 1:
        _logScreenKey.currentState?.refresh();
        break;
      case 2:
        _progressScreenKey.currentState?.refresh();
        break;
      case 3:
        _calendarScreenKey.currentState?.refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const TimerScreen(),
          LogScreen(key: _logScreenKey),
          ProgressScreen(key: _progressScreenKey),
          CalendarScreen(key: _calendarScreenKey),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
