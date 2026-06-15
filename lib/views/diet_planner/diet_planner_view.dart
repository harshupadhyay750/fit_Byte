import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import '../../models/meal_model.dart';
import '../ai_chat/ai_chat_view.dart';

class DietPlannerView extends ConsumerStatefulWidget {
  const DietPlannerView({super.key});

  @override
  ConsumerState<DietPlannerView> createState() => _DietPlannerViewState();
}

class _DietPlannerViewState extends ConsumerState<DietPlannerView> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final goals = ref.watch(nutritionGoalsProvider);
    final dietPlan = ref.watch(dietPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diet Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showAITip(context),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please complete your profile to see your plan.'))
          : RefreshIndicator(
              onRefresh: () => ref.read(dietPlanProvider.notifier).generatePlan(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSyncStatus(ref).animate().fadeIn(),
                    const SizedBox(height: 24),
                    _buildProfileSummary(user, goals).animate().slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Your Goal Strategy'),
                    const SizedBox(height: 12),
                    _buildStrategyCard(context, user, goals).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Daily AI Meal Plan'),
                        if (dietPlan.isNotEmpty)
                          TextButton.icon(
                            onPressed: _generatePlan,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Re-Generate'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (dietPlan.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: dietPlan.map((meal) => _buildMealCard(meal)).toList(),
                      ),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, user),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSyncStatus(WidgetRef ref) {
    final eaten = ref.watch(caloriesEatenProvider);
    final goal = ref.watch(caloriesGoalProvider);
    final percent = (eaten / goal).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dashboard Sync: You have reached ${(percent * 100).toInt()}% of your daily goal.',
              style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No Plan Generated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Let our AI create a personalized meal plan for you based on your goals.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isGenerating ? null : _generatePlan,
            child: _isGenerating 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Generate My Plan'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    await ref.read(dietPlanProvider.notifier).generatePlan();
    setState(() => _isGenerating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Diet Plan Updated!'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _buildMealCard(dynamic meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMealColor(meal['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meal['type'].toString().toUpperCase(),
                    style: TextStyle(color: _getMealColor(meal['type']), fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                Text('${meal['calories']} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Text(meal['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallMacro('P', '${meal['protein']}g', Colors.blue),
                _buildSmallMacro('C', '${meal['carbs']}g', Colors.orange),
                _buildSmallMacro('F', '${meal['fat']}g', Colors.red),
                ElevatedButton(
                  onPressed: () => _logMealToDashboard(meal),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Log', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.05),
    );
  }

  void _logMealToDashboard(dynamic mealData) {
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: mealData['name'],
      subtitle: mealData['type'],
      calories: mealData['calories'],
      protein: mealData['protein'].toDouble(),
      carbs: mealData['carbs'].toDouble(),
      fat: mealData['fat'].toDouble(),
      icon: Icons.restaurant,
      time: DateTime.now(),
    );
    
    ref.read(mealsProvider.notifier).addMeal(newMeal);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged ${mealData['name']} to Dashboard!'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'UNDO', onPressed: () => ref.read(mealsProvider.notifier).deleteMeal(newMeal.id)),
      ),
    );
  }

  Widget _buildSmallMacro(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label:', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _getMealColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast': return Colors.orange;
      case 'lunch': return Colors.green;
      case 'dinner': return Colors.indigo;
      default: return Colors.purple;
    }
  }

  Widget _buildProfileSummary(user, goals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWhiteMiniStat('Goal Weight', '${user.goalWeight}kg'),
              _buildWhiteMiniStat('Daily Target', '${goals['calories']} kcal'),
              _buildWhiteMiniStat('Diet Preference', user.dietaryPreference),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildStrategyCard(BuildContext context, user, goals) {
    String strategy = user.goalWeight < user.weight ? 'Weight Loss Deficit' : 'Muscle Gain Surplus';
    if (user.goalWeight == user.weight) strategy = 'Maintenance Plan';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.blue),
              const SizedBox(width: 12),
              Text(strategy, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To reach ${user.goalWeight}kg, your personalized plan focuses on a daily intake of ${goals['calories']} calories with optimized macro-nutrients.',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroTag('Protein: ${goals['protein']}g', Colors.blue),
              _buildMacroTag('Carbs: ${goals['carbs']}g', Colors.orange),
              _buildMacroTag('Fat: ${goals['fat']}g', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildActionButtons(BuildContext context, user) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToAIChat(context, user),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat with Diet AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to Analytics tab (assuming index 2)
            ref.read(navigationProvider.notifier).state = 2;
          },
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('View Nutrition Analytics'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  void _navigateToAIChat(BuildContext context, user) {
    final prompt = 'Help me refine my diet plan. I am ${user.age} years old, weigh ${user.weight}kg, goal is ${user.goalWeight}kg. Preference: ${user.dietaryPreference}.';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AIChatView(initialMessage: prompt)),
    );
  }

  void _showAITip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Diet Tip'),
        content: const Text('Consistency is key! Following this plan for 21 days will help your body adapt to a healthier metabolic rate.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }
}
