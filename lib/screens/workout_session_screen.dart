import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;
  final Function(Workout) onComplete;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
    required this.onComplete,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  Timer? _timer;

  Exercise get _currentExercise => widget.workout.exercises[_currentExerciseIndex];
  bool get _isLastExercise => _currentExerciseIndex == widget.workout.exercises.length - 1;
  bool get _isLastSet => _currentSet >= _currentExercise.sets;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restTimeRemaining = _currentExercise.restSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restTimeRemaining > 0) {
          _restTimeRemaining--;
        } else {
          _timer?.cancel();
          _isResting = false;
          _nextSet();
        }
      });
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _nextSet();
    });
  }

  void _nextSet() {
    if (_currentSet < _currentExercise.sets) {
      setState(() {
        _currentSet++;
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
      });
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() {
    final completedWorkout = widget.workout.copyWith(
      completedAt: DateTime.now(),
    );
    widget.onComplete(completedWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isResting ? Colors.orange[50] : Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            _showQuitDialog();
          },
        ),
        title: Text(
          'Exercise ${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: _isResting ? _buildRestScreen() : _buildExerciseScreen(),
      ),
    );
  }

  Widget _buildExerciseScreen() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar(),
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      _currentExercise.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _currentExercise.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSetInfo(),
                  const SizedBox(height: 24),
                  _buildExerciseDetails(),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildRestScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.timer,
          size: 80,
          color: Colors.orange,
        ),
        const SizedBox(height: 24),
        const Text(
          'Rest Time',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _formatTime(_restTimeRemaining),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _skipRest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip Rest',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Next: ${_isLastSet ? (_isLastExercise ? 'Complete!' : widget.workout.exercises[_currentExerciseIndex + 1].name) : _currentExercise.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentExerciseIndex + 1) / widget.workout.exercises.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workout Progress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(_currentExerciseIndex + 1)}/${widget.workout.exercises.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      ],
    );
  }

  Widget _buildSetInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Set $_currentSet of ${_currentExercise.sets}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_currentExercise.sets, (index) {
              final isCompleted = index < _currentSet - 1;
              final isCurrent = index == _currentSet - 1;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent ? Colors.blue[700] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.repeat, 'Sets', '${_currentExercise.sets}'),
          const Divider(height: 24),
          _buildDetailRow(Icons.format_list_numbered, 'Reps', '${_currentExercise.reps}'),
          const Divider(height: 24),
          _buildDetailRow(Icons.timer, 'Rest', '${_currentExercise.restSeconds}s'),
          const Divider(height: 24),
          _buildDetailRow(Icons.fitness_center, 'Equipment', _currentExercise.equipment),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_isLastSet && _isLastExercise) {
                  _completeWorkout();
                } else {
                  _startRest();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isLastSet && _isLastExercise ? 'Complete Workout' : 'Set Complete',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (!_isLastSet || !_isLastExercise) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (_isLastSet) {
                    _nextExercise();
                  } else {
                    _nextSet();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isLastSet ? 'Skip to Next Exercise' : 'Skip Rest'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Workout?'),
        content: const Text('Are you sure you want to quit this workout? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
