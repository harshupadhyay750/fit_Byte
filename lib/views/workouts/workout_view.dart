import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import '../../models/workout_model.dart';
import 'package:intl/intl.dart';

class WorkoutView extends ConsumerWidget {
  const WorkoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutProvider);
    final totalBurned = ref.watch(caloriesBurnedTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddWorkoutDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(totalBurned).animate().fadeIn().slideY(begin: -0.1),
          Expanded(
            child: workouts.isEmpty
                ? _buildEmptyState(context, ref)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return _buildWorkoutItem(workout).animate(delay: (index * 100).ms).fadeIn().slideX();
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkoutDialog(context, ref),
        icon: const Icon(Icons.fitness_center),
        label: const Text('Log Workout'),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('Calories Burned Today', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('$total kcal', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No workouts logged yet', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _showAddWorkoutDialog(context, ref),
            child: const Text('Start Tracking'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.grey[100],
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.bolt, color: Colors.orange),
        ),
        title: Text(workout.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${workout.duration} mins • ${DateFormat('MMM dd').format(workout.date)}'),
        trailing: Text(
          '-${workout.caloriesBurned} kcal',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
        ),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final durationController = TextEditingController();
    final caloriesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 32, left: 24, right: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Log New Workout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Exercise Name', prefixIcon: Icon(Icons.fitness_center)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration (min)', prefixIcon: Icon(Icons.timer)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories Burned', prefixIcon: Icon(Icons.local_fire_department)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final workout = Workout(
                      title: titleController.text,
                      duration: int.tryParse(durationController.text) ?? 30,
                      caloriesBurned: int.tryParse(caloriesController.text) ?? 200,
                      date: DateTime.now(),
                    );
                    ref.read(workoutProvider.notifier).addWorkout(workout);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Workout'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
