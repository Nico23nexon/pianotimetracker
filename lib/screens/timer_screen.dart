import 'dart:async';
import 'package:flutter/material.dart';
import '../models/practice_session.dart';
import '../services/storage_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final StorageService _storageService = StorageService();
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _hasStarted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _hasStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
      _hasStarted = false;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _endSession() async {
    final pieceNameController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'End Practice Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pieceNameController,
              decoration: const InputDecoration(
                labelText: 'Piece Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (pieceNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Piece name is required'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'pieceName': pieceNameController.text.trim(),
                      'notes': notesController.text.trim(),
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (result != null) {
      if (_elapsedSeconds > 0) {
        final session = PracticeSession(
          pieceName: result['pieceName']!,
          notes: result['notes']!,
          durationSeconds: _elapsedSeconds,
          date: DateTime.now(),
        );
        await _storageService.addSession(session);
        _resetTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session saved successfully'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_elapsedSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  IconButton.filled(
                    onPressed: _startTimer,
                    iconSize: 48,
                    icon: const Icon(Icons.play_arrow),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(80, 80),
                    ),
                  )
                else
                  IconButton.filled(
                    onPressed: _pauseTimer,
                    iconSize: 48,
                    icon: const Icon(Icons.pause),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(80, 80),
                    ),
                  ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: _resetTimer,
                  iconSize: 48,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(80, 80),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hasStarted ? _endSession : null,
        icon: const Icon(Icons.check),
        label: const Text('End Session'),
      ),
    );
  }
}

