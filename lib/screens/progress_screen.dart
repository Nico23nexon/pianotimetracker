import 'package:flutter/material.dart';
import '../models/practice_session.dart';
import '../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  final StorageService _storageService = StorageService();
  List<PracticeSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> refresh() async {
    await _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await _storageService.loadSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, int> _getPieceStats() {
    final Map<String, int> pieceStats = {};
    for (var session in _sessions) {
      pieceStats[session.pieceName] =
          (pieceStats[session.pieceName] ?? 0) + session.durationSeconds;
    }
    return pieceStats;
  }

  Map<DateTime, int> _getDailyStats() {
    final Map<DateTime, int> dailyStats = {};
    for (var session in _sessions) {
      final date = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      dailyStats[date] = (dailyStats[date] ?? 0) + session.durationSeconds;
    }
    return dailyStats;
  }

  int _getTotalDuration() {
    return _sessions.fold(0, (sum, session) => sum + session.durationSeconds);
  }

  int _getThisWeekDuration() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return _sessions
        .where((session) {
          final sessionDate = DateTime(
            session.date.year,
            session.date.month,
            session.date.day,
          );
          return sessionDate.isAfter(weekStartDate.subtract(const Duration(days: 1)));
        })
        .fold(0, (sum, session) => sum + session.durationSeconds);
  }

  int _getThisMonthDuration() {
    final now = DateTime.now();
    final monthStartDate = DateTime(now.year, now.month, 1);
    
    return _sessions
        .where((session) {
          final sessionDate = DateTime(
            session.date.year,
            session.date.month,
            session.date.day,
          );
          return sessionDate.isAfter(monthStartDate.subtract(const Duration(days: 1)));
        })
        .fold(0, (sum, session) => sum + session.durationSeconds);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalDuration = _getTotalDuration();
    final thisWeekDuration = _getThisWeekDuration();
    final thisMonthDuration = _getThisMonthDuration();
    final pieceStats = _getPieceStats();
    final sortedPieces = pieceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No practice data yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Practice',
                          value: _formatDuration(totalDuration),
                          icon: Icons.timer_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'This Week',
                          value: _formatDuration(thisWeekDuration),
                          icon: Icons.calendar_view_week,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'This Month',
                          value: _formatDuration(thisMonthDuration),
                          icon: Icons.calendar_month,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Sessions',
                          value: '${_sessions.length}',
                          icon: Icons.music_note,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Top Pieces
                  if (sortedPieces.isNotEmpty) ...[
                    Text(
                      'Most Practiced Pieces',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...sortedPieces.take(5).map((entry) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.piano,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              _formatDuration(entry.value),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Streak Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Practice Streak',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _calculateStreak(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _calculateStreak() {
    if (_sessions.isEmpty) {
      return const Text('No practice sessions yet');
    }

    final dailyStats = _getDailyStats();
    final sortedDates = dailyStats.keys.toList()..sort((a, b) => b.compareTo(a));
    
    if (sortedDates.isEmpty) {
      return const Text('No practice sessions yet');
    }

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    DateTime currentDate = todayDate;
    
    // Check if today has practice
    if (dailyStats.containsKey(currentDate)) {
      streak = 1;
      currentDate = currentDate.subtract(const Duration(days: 1));
      
      // Count consecutive days
      while (dailyStats.containsKey(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    } else {
      // If no practice today, check yesterday
      currentDate = currentDate.subtract(const Duration(days: 1));
      if (dailyStats.containsKey(currentDate)) {
        streak = 1;
        currentDate = currentDate.subtract(const Duration(days: 1));
        
        while (dailyStats.containsKey(currentDate)) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        }
      }
    }

    return Text(
      streak > 0
          ? '$streak day${streak > 1 ? 's' : ''} in a row! 🔥'
          : 'Start practicing to build a streak!',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

