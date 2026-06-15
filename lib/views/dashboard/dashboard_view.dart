import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/providers.dart';
import '../../models/meal_model.dart';
import '../workouts/workout_view.dart';
import 'package:intl/intl.dart';

import '../settings/profile_view.dart';
import '../bmi/bmi_calculator_view.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Add a nice haptic or visual feedback
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dashboard Updated'), duration: Duration(milliseconds: 500)),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAIInsightCard(context, ref).animate().fadeIn(duration: 800.ms).slideX(begin: -0.1),
              const SizedBox(height: 24),
              _buildCalorieCard(context, ref).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),
              _buildMacroRow(ref).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              const SizedBox(height: 24),
              
              _buildInteractiveTools(context, ref).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              
              _buildWaterIntakeCard(context, ref).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Meals',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => _showAddMealDialog(context, ref),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMealList(meals, ref),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log Meal'),
      ).animate().scale(delay: 1000.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAIInsightCard(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(aiInsightProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 2000.ms, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FitByte AI Insight',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                insight.when(
                  data: (text) => Text(
                    text,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (err, _) => const Text('Unable to fetch insight.', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTools(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tools',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildToolCard(
                context,
                'Workout',
                'Log Exercise',
                Icons.fitness_center,
                Colors.deepOrange,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutView()));
                },
              ),
              const SizedBox(width: 12),
              _buildToolCard(
                context,
                'Smart Suggest',
                'AI Meal Idea',
                Icons.lightbulb,
                Colors.amber,
                () => _showSmartSuggestDialog(context, ref),
              ),
              const SizedBox(width: 12),
              _buildToolCard(
                context,
                'Macro Calc',
                'By Weight',
                Icons.calculate,
                Colors.purple,
                () => _showWeightToMacroDialog(context, ref),
              ),
              const SizedBox(width: 12),
              _buildToolCard(
                context,
                'AI Scanner',
                'Scan Food',
                Icons.auto_awesome,
                Colors.teal,
                () => _showAIMacroDialog(context, ref),
              ),
              const SizedBox(width: 12),
              _buildToolCard(
                context,
                'BMI Tool',
                'Check Health',
                Icons.monitor_weight_outlined,
                Colors.orange,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BMICalculatorView()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSmartSuggestDialog(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            const Text('Smart Suggestion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('AI is thinking of a meal that fits your remaining macros...', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FutureBuilder<String>(
              future: _getAISuggestion(ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Column(
                  children: [
                    Text(snapshot.data ?? 'Error getting suggestion', 
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Great, thanks!'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAISuggestion(WidgetRef ref) async {
    final caloriesGoal = ref.read(caloriesGoalProvider);
    final caloriesEaten = ref.read(caloriesEatenProvider);
    final remaining = caloriesGoal - caloriesEaten;
    
    final prompt = "I have $remaining calories left for the day. Suggest one healthy meal or snack that I should eat to stay on track. Be concise.";
    return await ref.read(aiServiceProvider).getDietRecommendation(prompt);
  }


  Widget _buildToolCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 130, // Fixed width for horizontal scroll
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showWeightToMacroDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController(text: '100');
    final foodNameController = TextEditingController();
    bool loading = false;
    Map<String, dynamic>? results;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24, left: 24, right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weight Calculator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Get exact macros for any food weight', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: foodNameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    hintText: 'e.g. Avocado',
                    prefixIcon: const Icon(Icons.set_meal_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (Grams)',
                    suffixText: 'g',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (results != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildResultRow('Calories', '${results!['calories']} kcal', Colors.blue),
                        const Divider(),
                        _buildResultRow('Protein', '${results!['protein']}g', Colors.orange),
                        _buildResultRow('Carbs', '${results!['carbs']}g', Colors.green),
                        _buildResultRow('Fat', '${results!['fat']}g', Colors.red),
                      ],
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    if (results != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final meal = Meal(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: foodNameController.text,
                              subtitle: '${weightController.text}g - Calculated',
                              calories: results!['calories'],
                              protein: (results!['protein'] as num).toDouble(),
                              carbs: (results!['carbs'] as num).toDouble(),
                              fat: (results!['fat'] as num).toDouble(),
                              icon: Icons.calculate_outlined,
                              time: DateTime.now(),
                            );
                            ref.read(mealsProvider.notifier).addMeal(meal);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal Logged!')));
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Log This'),
                        ),
                      ),
                    if (results != null) const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: loading ? null : () async {
                          if (foodNameController.text.isEmpty) return;
                          setModalState(() => loading = true);
                          final w = double.tryParse(weightController.text) ?? 100.0;
                          final nutrition = await ref.read(aiServiceProvider).getNutritionData(foodNameController.text, w);
                          setModalState(() {
                            results = nutrition;
                            loading = false;
                          });
                        },
                        child: loading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(results == null ? 'Calculate Macros' : 'Recalculate'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  Widget _buildCalorieCard(BuildContext context, WidgetRef ref) {
    final caloriesEaten = ref.watch(caloriesEatenProvider);
    final caloriesBurned = ref.watch(caloriesBurnedTodayProvider);
    final caloriesGoal = ref.watch(caloriesGoalProvider);
    
    final netCalories = caloriesEaten - caloriesBurned;
    final remaining = caloriesGoal - netCalories;
    final percent = (netCalories / caloriesGoal).clamp(0.0, 1.0);

    return InkWell(
      onTap: () => _showCalorieBreakdown(context, ref),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remaining',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  remaining.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCalorieMiniInfo('Eaten', caloriesEaten.toString()),
                    const SizedBox(width: 12),
                    _buildCalorieMiniInfo('Burned', caloriesBurned.toString()),
                    const SizedBox(width: 12),
                    _buildCalorieMiniInfo('Goal', caloriesGoal.toString()),
                  ],
                ),
              ],
            ),
            CircularPercentIndicator(
              radius: 55.0,
              lineWidth: 10.0,
              percent: percent,
              animation: true,
              animateFromLastPercent: true,
              center: Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              progressColor: Colors.white,
              backgroundColor: Colors.white24,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  void _showCalorieBreakdown(BuildContext context, WidgetRef ref) {
    final protein = ref.read(proteinEatenProvider);
    final carbs = ref.read(carbsEatenProvider);
    final fat = ref.read(fatEatenProvider);
    
    final pGoal = ref.read(proteinGoalProvider);
    final cGoal = ref.read(carbsGoalProvider);
    final fGoal = ref.read(fatGoalProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Macro Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDetailedMacroProgress('Protein', protein, pGoal, Colors.blue),
            const SizedBox(height: 16),
            _buildDetailedMacroProgress('Carbs', carbs, cGoal, Colors.orange),
            const SizedBox(height: 16),
            _buildDetailedMacroProgress('Fat', fat, fGoal, Colors.red),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Breakdown'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMacroProgress(String label, double eaten, double goal, Color color) {
    final percent = (eaten / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${eaten.toInt()} / ${goal.toInt()}g'),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 12.0,
          percent: percent,
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
          barRadius: const Radius.circular(6),
          animation: true,
        ),
      ],
    );
  }

  Widget _buildCalorieMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMacroRow(WidgetRef ref) {
    final protein = ref.watch(proteinEatenProvider);
    final carbs = ref.watch(carbsEatenProvider);
    final fat = ref.watch(fatEatenProvider);

    final pGoal = ref.watch(proteinGoalProvider);
    final cGoal = ref.watch(carbsGoalProvider);
    final fGoal = ref.watch(fatGoalProvider);

    return Row(
      children: [
        Expanded(child: _buildMacroItem('Protein', '${protein.toStringAsFixed(1)}/${pGoal.toInt()}g', (protein / pGoal).clamp(0.0, 1.0), Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildMacroItem('Carbs', '${carbs.toStringAsFixed(1)}/${cGoal.toInt()}g', (carbs / cGoal).clamp(0.0, 1.0), Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildMacroItem('Fat', '${fat.toStringAsFixed(1)}/${fGoal.toInt()}g', (fat / fGoal).clamp(0.0, 1.0), Colors.red)),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6.0,
            percent: percent,
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
            barRadius: const Radius.circular(3),
            animation: true,
            animateFromLastPercent: true,
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeCard(BuildContext context, WidgetRef ref) {
    final waterIntake = ref.watch(waterIntakeProvider);
    final waterGoal = ref.watch(dailyWaterGoalProvider);
    final percent = (waterIntake / waterGoal).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        ref.read(waterIntakeProvider.notifier).state += 250;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added 250ml water! 💧'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 4.0,
                  percent: percent,
                  progressColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animateFromLastPercent: true,
                ),
                const Icon(Icons.water_drop, color: Colors.blue, size: 24),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Water Intake',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '$waterIntake / $waterGoal ml',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8.0,
                    percent: percent,
                    progressColor: Colors.blue,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    barRadius: const Radius.circular(4),
                    animation: true,
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle, color: Colors.blue, size: 32).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(List<Meal> meals, WidgetRef ref) {
    if (meals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No meals logged today', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildMealItem(context, meal, ref).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  Widget _buildMealItem(BuildContext context, Meal meal, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _showMealDetailDialog(context, meal),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Icon(meal.icon, color: Colors.orange),
          ),
          title: Text(meal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${meal.subtitle} • ${DateFormat('HH:mm').format(meal.time)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(
                    'P:${meal.protein.toInt()} C:${meal.carbs.toInt()} F:${meal.fat.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () {
                  ref.read(mealsProvider.notifier).deleteMeal(meal.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMealDetailDialog(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged at ${DateFormat('HH:mm').format(meal.time)}'),
            const Divider(height: 32),
            _buildResultRow('Calories', '${meal.calories} kcal', Colors.blue),
            _buildResultRow('Protein', '${meal.protein.toStringAsFixed(1)}g', Colors.orange),
            _buildResultRow('Carbs', '${meal.carbs.toStringAsFixed(1)}g', Colors.green),
            _buildResultRow('Fat', '${meal.fat.toStringAsFixed(1)}g', Colors.red),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Meal Name (e.g. Snack)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final calories = int.tryParse(caloriesController.text) ?? 0;
              if (title.isNotEmpty && calories > 0) {
                final newMeal = Meal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  subtitle: 'Manual Entry',
                  calories: calories,
                  icon: Icons.restaurant,
                  time: DateTime.now(),
                  // Default macros for manual entry
                  protein: (calories * 0.2) / 4,
                  carbs: (calories * 0.5) / 4,
                  fat: (calories * 0.3) / 9,
                );
                ref.read(mealsProvider.notifier).addMeal(newMeal);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAIMacroDialog(BuildContext context, WidgetRef ref) {
    final foodController = TextEditingController();
    final weightController = TextEditingController(text: '100');
    final ImagePicker picker = ImagePicker();
    XFile? image;
    bool detecting = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImage() async {
            final XFile? selected = await picker.pickImage(source: ImageSource.camera);
            if (selected != null) {
              setModalState(() => image = selected);
            }
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24, left: 24, right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.auto_awesome, color: Colors.teal),
                        ),
                        const SizedBox(width: 12),
                        const Text('AI Nutrition Scanner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                if (image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(image!.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                  )
                else
                  InkWell(
                    onTap: pickImage,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 32),
                          const SizedBox(height: 8),
                          Text('Snap food to analyze', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                TextField(
                  controller: foodController,
                  decoration: InputDecoration(
                    labelText: 'What is this?',
                    hintText: 'e.g. Pasta carbonara',
                    prefixIcon: const Icon(Icons.restaurant),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Estimated Weight',
                    suffixText: 'g',
                    prefixIcon: const Icon(Icons.scale),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: detecting ? null : () async {
                      if (foodController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please name the food')));
                        return;
                      }
                      setModalState(() => detecting = true);
                      
                      final weight = double.tryParse(weightController.text) ?? 100.0;
                      final nutrition = await ref.read(aiServiceProvider).getNutritionData(foodController.text, weight);
                      
                      final newMeal = Meal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: foodController.text,
                        subtitle: '${weight.toInt()}g - AI Scanned',
                        calories: nutrition['calories'] as int,
                        protein: (nutrition['protein'] as num).toDouble(),
                        carbs: (nutrition['carbs'] as num).toDouble(),
                        fat: (nutrition['fat'] as num).toDouble(),
                        icon: Icons.psychology_outlined,
                        time: DateTime.now(),
                      );
                      
                      await ref.read(mealsProvider.notifier).addMeal(newMeal);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logged ${foodController.text}!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: detecting 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Analyze & Log Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
