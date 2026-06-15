import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';

class AnalyticsView extends ConsumerStatefulWidget {
  const AnalyticsView({super.key});

  @override
  ConsumerState<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AICategory {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _AICategory(this.title, this.value, this.icon, this.color);
}

class _AnalyticsViewState extends ConsumerState<AnalyticsView> {
  String _timeRange = 'Weekly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeRangeToggle(),
            const SizedBox(height: 24),
            _buildChartCard(
              context,
              'Weight Progress',
              'Goal: ${ref.watch(userProvider)?.goalWeight ?? "--"} kg',
              _buildWeightChart(),
              Icons.monitor_weight_outlined,
              Colors.blue,
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 24),
            _buildChartCard(
              context,
              'Calorie Intake',
              'Daily Target: ${ref.watch(caloriesGoalProvider)} kcal',
              _buildCalorieChart(),
              Icons.local_fire_department_outlined,
              Colors.orange,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            const Text(
              'Nutrient Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            _buildNutrientPieChart().animate().fadeIn(delay: 500.ms).scale(),
            const SizedBox(height: 24),
            _buildAIPredictions().animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Weekly', 'Monthly'].map((range) {
          final isSelected = _timeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _timeRange = range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : null,
                ),
                child: Center(
                  child: Text(
                    range,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAIPredictions() {
    final predictions = [
      _AICategory('Est. Goal Date', 'Nov 12', Icons.event, Colors.green),
      _AICategory('Weekly Avg', '1,950 kcal', Icons.analytics, Colors.blue),
      _AICategory('Trend', '-0.4 kg/week', Icons.trending_down, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Health Predictions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final item = predictions[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.color.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color, size: 24),
                  const SizedBox(height: 8),
                  Text(item.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(item.value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: item.color)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, String title, String subtitle, Widget chart, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 75.5),
              const FlSpot(1, 75.2),
              const FlSpot(2, 75.8),
              const FlSpot(3, 75.0),
              const FlSpot(4, 74.8),
              const FlSpot(5, 74.5),
              const FlSpot(6, 74.2),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 1800),
          _buildBarGroup(1, 2100),
          _buildBarGroup(2, 1900),
          _buildBarGroup(3, 2300),
          _buildBarGroup(4, 1700),
          _buildBarGroup(5, 2000),
          _buildBarGroup(6, 1950),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.orange.withOpacity(0.8),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildNutrientPieChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.red, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PieIndicator(color: Colors.blue, text: 'Protein'),
              _PieIndicator(color: Colors.orange, text: 'Carbs'),
              _PieIndicator(color: Colors.red, text: 'Fat'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieIndicator extends StatelessWidget {
  final Color color;
  final String text;
  const _PieIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
